module SiSU_Viz
  require "#{SiSU_lib}/defaults" #<url:zxy_defaults.rb>
  class Skin
  #% path
    def path_root
      './sisu/'  # the only parameter that cannot be changed here
    end
    def path_rel
      '../'
    end
  #% url
    def url_root_http
      'http://live-systems.org/manual/'
    end
    def url_home
      'http://live-systems.org/'
    end
    def url_site # used in pdf header
      'http://live-systems.org'
    end
    def url_txt # text to go with url usually stripped url
      ''
    end
    def url_home_url
      '../index.html'
    end
    def url_footer_signature
      ''
    end
  #% color
    def color_band1
      '"#ffffff"'
    end
    def color_band2
      '"#ffffff"'
    end
  #% txt
    def txt_hp
      '&nbsp;Debian'
    end
    def txt_home
      'Debian'
    end
    def txt_signature
      ''
    end
  #% icon
    def icon_home_button
      'debian_home.png'
    end
    def icon_home_banner
      home_button
    end
  #% banner
    def banner_home_button
      %{<table summary="home button" border="0" cellpadding="3" cellspacing="0"><tr><td align="left" bgcolor="#ffffff"><a href="#{url_site}/">#{png_home}</a></td></tr></table>\n}
    end
    def banner_home_and_index_buttons
      %{<table><tr><td width="20%"><table summary="home and index buttons" border="0" cellpadding="3" cellspacing="0"><tr><td align="left" bgcolor="#ffffff"><a href="#{url_site}/" target="_top">#{png_home}</a>#{table_close}</td><td width="60%"><center><center><table summary="buttons" border="1" cellpadding="3" cellspacing="0"><tr><td align="center" bgcolor="#ffffff"><font face="arial" size="2"><a href="toc" target="_top">&nbsp;This&nbsp;text&nbsp;sub-&nbsp;<br />&nbsp;Table&nbsp;of&nbsp;Contents&nbsp;</a></font>#{table_close}</center></center></td><td width="20%">&nbsp;#{table_close}}
    end
    def banner_band
      %{<table summary="band" border="0" cellpadding="3" cellspacing="0"><tr><td align="left" bgcolor="#ffffff"><a href="#{url_site}/" target="_top">#{png_home}</a>#{table_close}}
    end
  end
  class TeX
    def header_center
      "\\chead{\\href{#{@vz.url_site}/}{live-systems.org}}"
    end
    def home_url
      "\\href{#{@vz.url_site}/}{live-systems.org}"
    end
    def home
      "\\href{#{@vz.url_site}/}{Live Systems}"
    end
    def owner_chapter
      "Document owner details"
    end
  end
end
