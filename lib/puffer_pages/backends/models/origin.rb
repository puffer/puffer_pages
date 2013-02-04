class PufferPages::Backends::Origin < ActiveRecord::Base
  self.abstract_class = true
  self.table_name = :origins

  attr_protected

  validates_presence_of :name, :host, :token
  validates_uniqueness_of :name

  def path
    read_attribute(:path).presence || PufferPages.export_path
  end

  def uri
    parsed_host.merge URI::Generic.build(:path => path, :query => { :token => token }.to_query)
  end

  def import!
    import_json import_data
  end

  def import_data
    Net::HTTP.get(uri)
  rescue
    raise PufferPages::ImportFailed.new("Could not connect to `#{name}` (#{uri})")
  end

  def import_json json
    data = json.is_a?(String) ? ActiveSupport::JSON.decode(json) : json
    ActiveRecord::Base.transaction do
      %w(layouts snippets pages).each do |table|
        klass = "puffer_pages/#{table}".classify.constantize
        klass.import_json data[table]
      end
    end
  end

  def self.export_json
    %w(layouts snippets pages).each_with_object({}) do |table, result|
      klass = "puffer_pages/#{table}".classify.constantize
      result[table] = klass.export_json
    end.as_json.to_json
  end

private

  def parsed_host
    URI.parse([scheme, real_host].join('://'))
  end

  def real_host
    host.gsub(/\Ahttps?\:\/\//, '')
  end

  def scheme
    match = host.match(/\A(https?)\:\/\//)
    match ? match[1] : 'http'
  end
end
