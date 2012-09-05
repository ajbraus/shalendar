class ScalingJob
  extend HerokuResqueAutoScale

  def self.perform
    # Do something long running
  end
end