# frozen_string_literal: true

require_relative 'exporters/exporter'
require_relative 'exporters/html_exporter'
require_relative 'exporters/id_generator'
require_relative 'exporters/json_exporter'
require_relative 'exporters/serializers'

module Dragnet
  # Namespace for the exporters: classes that produce files, or reports out of
  # the results of the Manual Test Record verification execution.
  module Exporters; end
end
