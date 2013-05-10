xml.instruct!
xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
  sitemap.resources.each do |resource|
    xml.url do
      xml.loc "#{data.site.url}#{resource.url}"
      xml.lastmod File.mtime(resource.source_file).strftime("%FT%T%:z")
    end if valid_sitemap_resource? resource.url
  end
end
