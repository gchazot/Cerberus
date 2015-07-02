class StatsManager
  CLIENT_APPLICATION_METRIC = "client_applications.number"
  AUTHORIZE_METRIC = "authorize."
  LOGIN_METRIC = "login."

  def initialize()
    # StatsManager client to manage data feed with StatsD
    if STATSD_SERVER_HOST
      @enabled = true
      @statsd = Statsd.new(STATSD_SERVER_HOST, STATSD_SERVER_PORT).tap{|sd| sd.namespace = STATSD_KEYPREFIX}
    end

  end

  # sends the application count
  def feedClientApplicationMetric()
    if @enabled
      @statsd.gauge CLIENT_APPLICATION_METRIC, ClientApplication.count
    end
  end

  # increments as soon as an authorization is done
  def feedAuthorizeMetric(user, client_application)
    if @enabled and user
      user_department = user.all_info[:department]
      @statsd.increment AUTHORIZE_METRIC + 'global'
      @statsd.increment AUTHORIZE_METRIC + client_application.name + '.global'
      @statsd.increment AUTHORIZE_METRIC + client_application.name + '.' + user_department
    end
  end

  # increments as soon as a login is done
  def feedLoginMetric(user)
    if @enabled and user
      user_department = user.all_info[:department]
      @statsd.increment LOGIN_METRIC + 'global'
      @statsd.increment LOGIN_METRIC + user_department
    end
  end
end
