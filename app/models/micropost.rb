class Micropost < ActiveRecord::Base
  attr_accessible :content, :in_reply_to, :has_provenance, :user, :bundle_number
  belongs_to :user

  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  default_scope order: 'microposts.created_at DESC'

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", 
          user_id: user.id)
  end


  def generate_provenance
    require 'ProvRequests'
    require 'json'
    require 'active_support/core_ext/hash/deep_merge'

    #if it's blank, standard prov
    new_bundle = {
      "prefix" => {
        "ex"=> "http://localhost:3001" #change to sensible url
      },
      "entity"=>{
        "ex:Micropost#{self.id.to_s}"=>{

        }
      },
      "activity"=>{
          "ex:Post#{self.id.to_s}"=>{
              "startTime"=> ["#{strip_time(Time.now)}", "xsd:dateTime"],
              #it is assumed it takes one second
              "endTime"=> ["#{strip_time(Time.now+1)})" , "xsd:dateTime"],
              "prov:type"=>"Download #{self.id}"
          }
      },
      "agent"=>{
        "ex:#{self.user.name}"=>{

        }
      },
      "wasGeneratedBy"=>{
          "ex:ge#{self.id.to_s}"=>{
              "prov:entity"=>"ex:Micropost#{self.id.to_s}",
              "prov:activity"=> "ex:Post#{self.id.to_s}"
          }
      },
      "wasAssociatedWith"=>{
        "ex:assoc#{self.id.to_s}"=>{
          "prov:activity"=>"ex:Post#{self.id.to_s}",
          "prov:agent"=>"ex:#{self.user.name}"
        }
      },
      "wasAttributedTo"=> {
          "ex:att#{self.id.to_s}"=>{
              "prov:agent"=> "ex:#{self.user.name}",
              "prov:entity"=> "ex:Micropost#{self.id.to_s}"
          }
      }
    }
  
    #if it's a reply to an existing micropost.
    #has_provenance will be blank because it has no provenance until this method is run
    if !self.in_reply_to.blank? && self.has_provenance.blank?
      mp = Micropost.find(self.in_reply_to)
      prov_id = /(\d*)\.provn/.match(mp.has_provenance)
      if !prov_id.nil?
        prov_id = prov_id[1]
      end
      if !prov_id.blank?
        downloaded_prov = ProvRequests.get_request(self.user.prov_username, self.user.access_token, prov_id)
      
        if !downloaded_prov.blank?
            old_prov = ActiveSupport::JSON.decode(downloaded_prov)["prov_json"]
        end
        new_bundle = new_bundle.deep_merge(old_prov)
      end

      old_bundle  = {
        "entity"=>{
          "ex:Micropost#{mp.id.to_s}"=>{

          }
        },
        "agent"=>{
          "ex:#{self.user.name}"=>{

          }
        },
        "wasDerivedFrom"=>{
          "ex:de#{self.id.to_s}"=> {
            "prov:generatedEntity"=> "ex:Micropost#{self.id.to_s}",
            "prov:usedEntity"=> "ex:Micropost#{mp.id.to_s}"
          }
        }
      }

      new_bundle = new_bundle.deep_merge(old_bundle)

    # if it's a post from an external system
    # has provenance is also used to represent the passed in has_proveance from the external system. It is then overwritten.
    elsif !self.has_provenance.blank? && !self.in_reply_to.blank?
      prov_id = /(\d*)\.provn/.match(self.has_provenance)

      if !self.bundle_number.nil?
        ob = {
          "wasDerivedFrom"=>{
            "ex:de#{self.id.to_s}#{self.bundle_number}"=> {
              "prov:generatedEntity"=> "ex:Micropost#{self.id.to_s}",
              "prov:usedEntity"=> "Micropost#{self.bundle_number}:bundle"
            }
          }
        }
        new_bundle = new_bundle.deep_merge(ob)
      end

      if !prov_id.nil?
        prov_id = prov_id[1]
      end

      if !prov_id.blank?
        downloaded_prov = ProvRequests.get_request(self.user.prov_username, self.user.access_token, prov_id)
      
        if !downloaded_prov.blank?
            old_prov = ActiveSupport::JSON.decode(downloaded_prov)["prov_json"]
        end

        new_bundle = new_bundle.deep_merge(old_prov)

        mp = Micropost.find(self.in_reply_to)
        old_bundle  = {
          "entity"=>{
            "ex:Micropost#{mp.id.to_s}"=>{

            }
          },
          "agent"=>{
            "ex:#{self.user.name}"=>{

            }
          },
          "wasDerivedFrom"=>{
            "ex:de#{self.id.to_s}"=> {
              "prov:generatedEntity"=> "ex:Micropost#{self.id.to_s}",
              "prov:usedEntity"=> "ex:Micropost#{mp.id.to_s}"
            }
          }
        }

        new_bundle = new_bundle.deep_merge(old_bundle)
      end
    end




    rec_id = "Micropost"+self.id.to_s
# debugger
    prov_json_results = ProvRequests.post_request(self.user.prov_username, self.user.access_token, new_bundle, rec_id)
    

    prov_hash_results = ActiveSupport::JSON.decode(prov_json_results)

    self.has_provenance = ENV['PROV_SERVER']+"/store/bundles/"+prov_hash_results["id"].to_s+".provn"



  end


  #this strips a time object to a prov correct string
  def strip_time(time)

    #split the time into an array.
    timeArray = time.to_s.split(/\s/)
    return timeArray[0]+"T"+timeArray[1]

  end



end
