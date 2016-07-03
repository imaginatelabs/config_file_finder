class Results
  attr_reader :result, :files, :message

  def initialize(result, files, message = nil)
    @result = result
    @files = files
    @message = message
  end

  def success?
    @result == :success
  end

  def failed?
    @result == :failed
  end
end
