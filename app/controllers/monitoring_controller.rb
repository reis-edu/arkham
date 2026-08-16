# frozen_string_literal: true

class MonitoringController < ApplicationController
  def show
    db_status = database_status

    render json: {
      arkham_api: { status: 'ok', message: 'We are fine!' },
      arkham_db: db_status
    }, status: db_status[:status] == 'ok' ? :ok : :service_unavailable
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    { status: 'ok', message: 'We are fine!' }
  rescue StandardError => e
    { status: 'fail', message: e.message }
  end
end
