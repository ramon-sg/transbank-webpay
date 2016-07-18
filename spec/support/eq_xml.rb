RSpec::Matchers.define :eq_xml do |xml|
  match do |actual_xml|
    clear(actual_xml) == clear(xml)
  end

  def clear(xml)
    xml.gsub(%r{\s*/?>\s*}, ">").gsub(%r{\s*/?<\s*}, "<")
  end
end
