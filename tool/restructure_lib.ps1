# MindLoop lib/ module-wise restructure script
$lib = "d:\Gayu - workspace\Mywork space\MindLoop\lib"

$moves = @(
    # App shell
    @("app.dart", "app/app.dart"),
    @("routes/app_router.dart", "app/router/app_router.dart"),
    @("core/di/injection.dart", "app/di/injection.dart"),

    # Shared theme & widgets
    @("themes/app_colors.dart", "shared/theme/app_colors.dart"),
    @("themes/app_decorations.dart", "shared/theme/app_decorations.dart"),
    @("themes/app_theme.dart", "shared/theme/app_theme.dart"),
    @("themes/calendar_ui_colors.dart", "shared/theme/calendar_ui_colors.dart"),
    @("themes/pfm_theme.dart", "shared/theme/pfm_theme.dart"),
    @("widgets/app_feedback.dart", "shared/widgets/app_feedback.dart"),
    @("widgets/app_list_rows.dart", "shared/widgets/app_list_rows.dart"),
    @("widgets/coming_soon_card.dart", "shared/widgets/coming_soon_card.dart"),
    @("widgets/dynamic_background.dart", "shared/widgets/dynamic_background.dart"),
    @("widgets/glass_card.dart", "shared/widgets/glass_card.dart"),
    @("widgets/glow_button.dart", "shared/widgets/glow_button.dart"),
    @("widgets/keyboard_dismiss_scope.dart", "shared/widgets/keyboard_dismiss_scope.dart"),
    @("widgets/mind_loop_logo.dart", "shared/widgets/mind_loop_logo.dart"),
    @("widgets/rigging_alarm_background.dart", "shared/widgets/rigging_alarm_background.dart"),

    # Core services (cross-module)
    @("services/notification_service.dart", "core/services/notification_service.dart"),

    # Auth module
    @("data/repositories/auth_repository_impl.dart", "modules/auth/data/repositories/auth_repository_impl.dart"),
    @("domain/repositories/auth_repository.dart", "modules/auth/domain/repositories/auth_repository.dart"),
    @("presentation/blocs/auth/auth_bloc.dart", "modules/auth/presentation/bloc/auth_bloc.dart"),
    @("presentation/blocs/auth/auth_event.dart", "modules/auth/presentation/bloc/auth_event.dart"),
    @("presentation/blocs/auth/auth_state.dart", "modules/auth/presentation/bloc/auth_state.dart"),
    @("presentation/screens/auth/login_screen.dart", "modules/auth/presentation/pages/login_screen.dart"),
    @("presentation/screens/auth/signup_screen.dart", "modules/auth/presentation/pages/signup_screen.dart"),
    @("presentation/screens/auth/forgot_password_screen.dart", "modules/auth/presentation/pages/forgot_password_screen.dart"),

    # Reminder module
    @("data/models/reminder_model.dart", "modules/reminder/data/models/reminder_model.dart"),
    @("data/repositories/reminder_repository_impl.dart", "modules/reminder/data/repositories/reminder_repository_impl.dart"),
    @("domain/entities/reminder_entity.dart", "modules/reminder/domain/entities/reminder_entity.dart"),
    @("domain/repositories/reminder_repository.dart", "modules/reminder/domain/repositories/reminder_repository.dart"),
    @("presentation/blocs/reminder/reminder_bloc.dart", "modules/reminder/presentation/bloc/reminder_bloc.dart"),
    @("presentation/blocs/reminder/reminder_event.dart", "modules/reminder/presentation/bloc/reminder_event.dart"),
    @("presentation/blocs/reminder/reminder_state.dart", "modules/reminder/presentation/bloc/reminder_state.dart"),
    @("presentation/screens/reminder/reminder_alert_screen.dart", "modules/reminder/presentation/pages/reminder_alert_screen.dart"),
    @("presentation/screens/reminder/reminder_create_screen.dart", "modules/reminder/presentation/pages/reminder_create_screen.dart"),
    @("presentation/screens/reminder/reminder_detail_screen.dart", "modules/reminder/presentation/pages/reminder_detail_screen.dart"),
    @("presentation/screens/calendar/calendar_screen.dart", "modules/reminder/presentation/pages/calendar_screen.dart"),
    @("core/constants/reminder_categories.dart", "modules/reminder/core/constants/reminder_categories.dart"),
    @("core/constants/reminder_ringtones.dart", "modules/reminder/core/constants/reminder_ringtones.dart"),
    @("core/utils/reminder_audio_permissions.dart", "modules/reminder/core/utils/reminder_audio_permissions.dart"),
    @("core/utils/reminder_sound_player.dart", "modules/reminder/core/utils/reminder_sound_player.dart"),
    @("services/custom_ringtone_service.dart", "modules/reminder/services/custom_ringtone_service.dart"),
    @("services/reminder_alarm_coordinator.dart", "modules/reminder/services/reminder_alarm_coordinator.dart"),
    @("services/reminder_alert_launcher.dart", "modules/reminder/services/reminder_alert_launcher.dart"),
    @("services/reminder_due_watcher.dart", "modules/reminder/services/reminder_due_watcher.dart"),
    @("services/reminder_notification_sound.dart", "modules/reminder/services/reminder_notification_sound.dart"),

    # Finance module
    @("data/models/budget_transaction_model.dart", "modules/finance/data/models/budget_transaction_model.dart"),
    @("data/repositories/budget_repository_impl.dart", "modules/finance/data/repositories/budget_repository_impl.dart"),
    @("data/repositories/pfm_repository_impl.dart", "modules/finance/data/repositories/pfm_repository_impl.dart"),
    @("domain/entities/budget_transaction_entity.dart", "modules/finance/domain/entities/budget_transaction_entity.dart"),
    @("domain/entities/expense_budget_entity.dart", "modules/finance/domain/entities/expense_budget_entity.dart"),
    @("domain/entities/expense_category_entity.dart", "modules/finance/domain/entities/expense_category_entity.dart"),
    @("domain/entities/financial_goal_entity.dart", "modules/finance/domain/entities/financial_goal_entity.dart"),
    @("domain/entities/loan_entity.dart", "modules/finance/domain/entities/loan_entity.dart"),
    @("domain/entities/net_worth_item_entity.dart", "modules/finance/domain/entities/net_worth_item_entity.dart"),
    @("domain/entities/pfm_dashboard_snapshot.dart", "modules/finance/domain/entities/pfm_dashboard_snapshot.dart"),
    @("domain/entities/recurring_transaction_entity.dart", "modules/finance/domain/entities/recurring_transaction_entity.dart"),
    @("domain/repositories/budget_repository.dart", "modules/finance/domain/repositories/budget_repository.dart"),
    @("domain/repositories/pfm_repository.dart", "modules/finance/domain/repositories/pfm_repository.dart"),
    @("presentation/blocs/budget/budget_bloc.dart", "modules/finance/presentation/bloc/budget_bloc.dart"),
    @("presentation/blocs/budget/budget_event.dart", "modules/finance/presentation/bloc/budget_event.dart"),
    @("presentation/blocs/budget/budget_state.dart", "modules/finance/presentation/bloc/budget_state.dart"),
    @("presentation/blocs/pfm/pfm_bloc.dart", "modules/finance/presentation/bloc/pfm_bloc.dart"),
    @("presentation/blocs/pfm/pfm_event.dart", "modules/finance/presentation/bloc/pfm_event.dart"),
    @("presentation/blocs/pfm/pfm_state.dart", "modules/finance/presentation/bloc/pfm_state.dart"),
    @("presentation/screens/pfm/expense_reminder_alert_screen.dart", "modules/finance/presentation/pages/expense_reminder_alert_screen.dart"),
    @("presentation/screens/pfm/pfm_add_sheets.dart", "modules/finance/presentation/pages/pfm_add_sheets.dart"),
    @("presentation/screens/pfm/pfm_analytics_screen.dart", "modules/finance/presentation/pages/pfm_analytics_screen.dart"),
    @("presentation/screens/pfm/pfm_budget_screen.dart", "modules/finance/presentation/pages/pfm_budget_screen.dart"),
    @("presentation/screens/pfm/pfm_categories_screen.dart", "modules/finance/presentation/pages/pfm_categories_screen.dart"),
    @("presentation/screens/pfm/pfm_dashboard_screen.dart", "modules/finance/presentation/pages/pfm_dashboard_screen.dart"),
    @("presentation/screens/pfm/pfm_export_screen.dart", "modules/finance/presentation/pages/pfm_export_screen.dart"),
    @("presentation/screens/pfm/pfm_goals_screen.dart", "modules/finance/presentation/pages/pfm_goals_screen.dart"),
    @("presentation/screens/pfm/pfm_insights_screen.dart", "modules/finance/presentation/pages/pfm_insights_screen.dart"),
    @("presentation/screens/pfm/pfm_loans_screen.dart", "modules/finance/presentation/pages/pfm_loans_screen.dart"),
    @("presentation/screens/pfm/pfm_net_worth_screen.dart", "modules/finance/presentation/pages/pfm_net_worth_screen.dart"),
    @("presentation/screens/pfm/pfm_notifications_screen.dart", "modules/finance/presentation/pages/pfm_notifications_screen.dart"),
    @("presentation/screens/pfm/pfm_transactions_screen.dart", "modules/finance/presentation/pages/pfm_transactions_screen.dart"),
    @("presentation/screens/pfm/pfm_utils.dart", "modules/finance/presentation/pages/pfm_utils.dart"),
    @("presentation/screens/analytics/analytics_screen.dart", "modules/finance/presentation/pages/analytics_screen.dart"),
    @("presentation/screens/budget/budget_screen.dart", "modules/finance/presentation/pages/budget_screen.dart"),
    @("widgets/pfm/expense_reminder_feedback.dart", "modules/finance/presentation/widgets/expense_reminder_feedback.dart"),
    @("widgets/pfm/pfm_charts.dart", "modules/finance/presentation/widgets/pfm_charts.dart"),
    @("widgets/pfm/pfm_drawer.dart", "modules/finance/presentation/widgets/pfm_drawer.dart"),
    @("widgets/pfm/pfm_empty_data.dart", "modules/finance/presentation/widgets/pfm_empty_data.dart"),
    @("widgets/pfm/pfm_expense_dashboard_widgets.dart", "modules/finance/presentation/widgets/pfm_expense_dashboard_widgets.dart"),
    @("widgets/pfm/pfm_expense_overview.dart", "modules/finance/presentation/widgets/pfm_expense_overview.dart"),
    @("widgets/pfm/pfm_form_fields.dart", "modules/finance/presentation/widgets/pfm_form_fields.dart"),
    @("widgets/pfm/pfm_money_overview.dart", "modules/finance/presentation/widgets/pfm_money_overview.dart"),
    @("widgets/pfm/pfm_summary_card.dart", "modules/finance/presentation/widgets/pfm_summary_card.dart"),
    @("widgets/pfm/pfm_ui_kit.dart", "modules/finance/presentation/widgets/pfm_ui_kit.dart"),
    @("core/constants/pfm_categories.dart", "modules/finance/core/constants/pfm_categories.dart"),
    @("core/constants/currency_options.dart", "modules/finance/core/constants/currency_options.dart"),
    @("core/constants/expense_reminder_constants.dart", "modules/finance/core/constants/expense_reminder_constants.dart"),
    @("core/utils/pfm_display_helpers.dart", "modules/finance/core/utils/pfm_display_helpers.dart"),
    @("core/utils/currency_preferences.dart", "modules/finance/core/utils/currency_preferences.dart"),
    @("core/utils/expense_reminder_preferences.dart", "modules/finance/core/utils/expense_reminder_preferences.dart"),
    @("services/expense_reminder_alert_launcher.dart", "modules/finance/services/expense_reminder_alert_launcher.dart"),
    @("services/expense_reminder_service.dart", "modules/finance/services/expense_reminder_service.dart"),
    @("services/expense_tracker_service.dart", "modules/finance/services/expense_tracker_service.dart"),
    @("services/finance_analytics_service.dart", "modules/finance/services/finance_analytics_service.dart"),
    @("services/finance_export_service.dart", "modules/finance/services/finance_export_service.dart"),
    @("services/finance_insights_service.dart", "modules/finance/services/finance_insights_service.dart"),

    # Dashboard module
    @("presentation/screens/dashboard/dashboard_screen.dart", "modules/dashboard/presentation/pages/dashboard_screen.dart"),

    # Home shell
    @("presentation/screens/home/home_shell.dart", "modules/home/presentation/pages/home_shell.dart"),

    # Settings module
    @("presentation/screens/settings/settings_screen.dart", "modules/settings/presentation/pages/settings_screen.dart"),
    @("presentation/screens/settings/expense_data_settings_section.dart", "modules/settings/presentation/pages/expense_data_settings_section.dart"),
    @("presentation/screens/settings/expense_reminder_settings_section.dart", "modules/settings/presentation/pages/expense_reminder_settings_section.dart"),

    # Profile module
    @("presentation/screens/profile/profile_screen.dart", "modules/profile/presentation/pages/profile_screen.dart"),

    # Onboarding module
    @("presentation/screens/splash/splash_screen.dart", "modules/onboarding/presentation/pages/splash_screen.dart"),
    @("presentation/screens/onboarding/onboarding_screen.dart", "modules/onboarding/presentation/pages/onboarding_screen.dart"),

    # Calculator module
    @("presentation/screens/calculator/calculator_screen.dart", "modules/calculator/presentation/pages/calculator_screen.dart"),
    @("core/utils/calculator_usage_tracker.dart", "modules/calculator/core/utils/calculator_usage_tracker.dart"),

    # Pomodoro module
    @("presentation/screens/pomodoro/pomodoro_screen.dart", "modules/pomodoro/presentation/pages/pomodoro_screen.dart"),
    @("core/utils/pomodoro_preferences.dart", "modules/pomodoro/core/utils/pomodoro_preferences.dart"),
    @("services/pomodoro_controller.dart", "modules/pomodoro/services/pomodoro_controller.dart"),

    # Legal module
    @("presentation/screens/legal/privacy_policy_screen.dart", "modules/legal/presentation/pages/privacy_policy_screen.dart"),
    @("presentation/screens/legal/terms_of_service_screen.dart", "modules/legal/presentation/pages/terms_of_service_screen.dart"),

    # Future / roadmap module
    @("presentation/screens/future/future_features_screen.dart", "modules/future/presentation/pages/future_features_screen.dart")
)

foreach ($pair in $moves) {
    $src = Join-Path $lib $pair[0]
    $dst = Join-Path $lib $pair[1]
    if (-not (Test-Path $src)) {
        Write-Warning "SKIP (missing): $($pair[0])"
        continue
    }
    $dstDir = Split-Path $dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Move-Item -Path $src -Destination $dst -Force
    Write-Host "Moved: $($pair[0]) -> $($pair[1])"
}

# Remove empty old directories
$oldDirs = @(
    "routes", "themes", "widgets", "services", "data", "domain", "presentation", "core/di"
)
foreach ($dir in $oldDirs) {
    $full = Join-Path $lib $dir
    if (Test-Path $full) {
        Get-ChildItem -Path $full -Recurse -Directory | Sort-Object FullName -Descending | ForEach-Object {
            if ((Get-ChildItem $_.FullName -Force | Measure-Object).Count -eq 0) {
                Remove-Item $_.FullName -Force
            }
        }
        if ((Get-ChildItem $full -Force | Measure-Object).Count -eq 0) {
            Remove-Item $full -Force -Recurse -ErrorAction SilentlyContinue
        }
    }
}

Write-Host "`nDone moving files."
