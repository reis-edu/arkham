# frozen_string_literal: true

Dir[Rails.root.join('lib/arkham/**/*.rb')].sort.each { |file| require file }
