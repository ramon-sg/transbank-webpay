module SpecSupport
  RSpec.configure do |config|
    config.include self
  end

  def open_xml(*args)
    xml_path = buiild_xml_path(*args)
    File.read(xml_path)
  end

  def buiild_xml_path(*args)
    ROOT_PATH.join(*(%w(spec support xml) + args))
  end

  def new_subject(xml_path = nil, action = :action)
    body = xml_path.nil? ? '<xml></xml>' : open_xml(xml_path)
    subject_class.new body: body, action: action
  end
end
