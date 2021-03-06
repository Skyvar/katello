module Actions
  module Katello
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        def resource_locks
          :link
        end

        input_format do
          param :name
        end

        def humanized_name
          _("Synchronize smart proxy")
        end

        def humanized_input
          input['smart_proxy'].nil? || input['smart_proxy']['name'].nil? ? super : ["'#{input['smart_proxy']['name']}'"] + super
        end

        def plan(smart_proxy, options = {})
          action_subject(smart_proxy)
          smart_proxy.verify_ueber_certs
          environment_id = options.fetch(:environment_id, nil)
          environment = ::Katello::KTEnvironment.find(environment_id) if environment_id
          repository_id = options.fetch(:repository_id, nil)
          repository = ::Katello::Repository.find(repository_id) if repository_id
          content_view_id = options.fetch(:content_view_id, nil)
          content_view = ::Katello::ContentView.find(content_view_id) if content_view_id

          fail _("Action not allowed for the default smart proxy.") if smart_proxy.pulp_master?

          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          repositories = smart_proxy_helper.repos_available_to_capsule(environment, content_view, repository)
          smart_proxy.ping_pulp3 if repositories.any? { |repo| smart_proxy.pulp3_support?(repo) }
          smart_proxy.ping_pulp if repositories.any? { |repo| !smart_proxy.pulp3_support?(repo) }

          refresh_options = options.merge(content_view: content_view,
                                             environment:  environment,
                                             repository: repository)
          sequence do
            plan_action(Actions::Pulp::Orchestration::Repository::RefreshRepos, smart_proxy, refresh_options)
            plan_action(Actions::Pulp3::Orchestration::Repository::RefreshRepos, smart_proxy, refresh_options) if smart_proxy.pulp3_enabled?
            plan_action(SyncCapsule, smart_proxy, refresh_options)
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
