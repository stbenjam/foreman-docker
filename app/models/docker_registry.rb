class DockerRegistry < ActiveRecord::Base
  include Authorizable
  include Taxonomix
  include Encryptable

  has_many :containers, :foreign_key => "registry_id", :dependent => :destroy
  encrypts :password

  scoped_search :on => :name, :complete_value => true
  scoped_search :on => :url

  def used_location_ids
    Location.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'DockerRegistry',
        'taxable_taxonomies.taxable_id' => id).pluck(:id)
  end

  def used_organization_ids
    Organization.joins(:taxable_taxonomies).where(
        'taxable_taxonomies.taxable_type' => 'DockerRegistry',
        'taxable_taxonomies.taxable_id' => id).pluck(:id)
  end

  def prefixed_url(image_name)
    uri = URI(url)
    "#{uri.hostname}:#{uri.port}/#{image_name}"
  end
end
