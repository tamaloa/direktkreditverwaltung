module ContractVersionsHelper
  def version_as_short_line(version)
    version_line = "##{version.version}"
    version_line << " seit #{version.start}"
    version_line << " verzinsung #{fraction version.interest_rate}"
    version_line
  end
end
