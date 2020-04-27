def attach(selector, path)
  script = "$(\"[name='#{selector}']\").css({opacity: 100, display: 'block', position: 'relative', left: ''});"
  page.execute_script(script)
  attach_file selector, path
end