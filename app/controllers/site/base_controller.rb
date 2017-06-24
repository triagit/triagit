module Site
  class BaseController < ::ApplicationController
    layout '../site/shared/layout'
    helper 'site/site'
  end
end
