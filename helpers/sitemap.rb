module Sitemap
  def valid_sitemap_resource? url
    url !~ /\.(css|js|eot|svg|woff|otf|ttf|png|jpg)$/
  end
end
