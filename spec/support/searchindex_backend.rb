module SearchindexBackendHelper

  def configure_elasticsearch(required: false)
    if ENV['ES_URL'].blank?
      return if !required

      raise "ERROR: Need ES_URL - hint ES_URL='http://127.0.0.1:9200'"
    end

    Setting.set('es_url', ENV['ES_URL'])

    # Setting.set('es_url', 'http://127.0.0.1:9200')
    # Setting.set('es_index', 'estest.local_zammad')
    # Setting.set('es_user', 'elasticsearch')
    # Setting.set('es_password', 'zammad')

    if ENV['ES_INDEX_RAND'].present?
      rand_id          = ENV.fetch('CI_JOB_ID', "r#{rand(999)}")
      test_method_name = subject.gsub(/[^\w]/, '_')
      ENV['ES_INDEX']  = "es_index_#{test_method_name}_#{rand_id}_#{rand(999_999_999)}"
    end
    if ENV['ES_INDEX'].blank?
      raise "ERROR: Need ES_INDEX - hint ES_INDEX='estest.local_zammad'"
    end

    Setting.set('es_index', ENV['ES_INDEX'])

    # set max attachment size in mb
    Setting.set('es_attachment_max_size_in_mb', 1)

    yield if block_given?
  end

  def rebuild_searchindex
    Rake::Task['searchindex:rebuild'].execute
  end

  def self.included(base)

    # Execute in RSpec class context
    base.class_exec do

      after(:each) do
        next if ENV['ES_URL'].blank?

        Rake::Task['searchindex:drop'].execute
      end
    end
  end
end

RSpec.configure do |config|
  config.include SearchindexBackendHelper, searchindex: true
end