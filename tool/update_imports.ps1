# Update all package:mindloop/ imports after module restructure
$lib = "d:\Gayu - workspace\Mywork space\MindLoop\lib"

# Order: longest/most-specific paths first
$replacements = [ordered]@{
    'package:mindloop/presentation/screens/pfm/pfm_transactions_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_transactions_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_notifications_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_notifications_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_net_worth_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_net_worth_screen.dart'
    'package:mindloop/presentation/screens/pfm/expense_reminder_alert_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/expense_reminder_alert_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_categories_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_categories_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_dashboard_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_dashboard_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_analytics_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_analytics_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_insights_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_insights_screen.dart'
    'package:mindloop/presentation/screens/settings/expense_reminder_settings_section.dart' = 'package:mindloop/modules/settings/presentation/pages/expense_reminder_settings_section.dart'
    'package:mindloop/presentation/screens/settings/expense_data_settings_section.dart' = 'package:mindloop/modules/settings/presentation/pages/expense_data_settings_section.dart'
    'package:mindloop/presentation/screens/reminder/reminder_create_screen.dart' = 'package:mindloop/modules/reminder/presentation/pages/reminder_create_screen.dart'
    'package:mindloop/presentation/screens/reminder/reminder_detail_screen.dart' = 'package:mindloop/modules/reminder/presentation/pages/reminder_detail_screen.dart'
    'package:mindloop/presentation/screens/reminder/reminder_alert_screen.dart' = 'package:mindloop/modules/reminder/presentation/pages/reminder_alert_screen.dart'
    'package:mindloop/presentation/screens/future/future_features_screen.dart' = 'package:mindloop/modules/future/presentation/pages/future_features_screen.dart'
    'package:mindloop/presentation/screens/legal/privacy_policy_screen.dart' = 'package:mindloop/modules/legal/presentation/pages/privacy_policy_screen.dart'
    'package:mindloop/presentation/screens/legal/terms_of_service_screen.dart' = 'package:mindloop/modules/legal/presentation/pages/terms_of_service_screen.dart'
    'package:mindloop/presentation/screens/pomodoro/pomodoro_screen.dart' = 'package:mindloop/modules/pomodoro/presentation/pages/pomodoro_screen.dart'
    'package:mindloop/presentation/screens/calculator/calculator_screen.dart' = 'package:mindloop/modules/calculator/presentation/pages/calculator_screen.dart'
    'package:mindloop/presentation/screens/onboarding/onboarding_screen.dart' = 'package:mindloop/modules/onboarding/presentation/pages/onboarding_screen.dart'
    'package:mindloop/presentation/screens/dashboard/dashboard_screen.dart' = 'package:mindloop/modules/dashboard/presentation/pages/dashboard_screen.dart'
    'package:mindloop/presentation/screens/profile/profile_screen.dart' = 'package:mindloop/modules/profile/presentation/pages/profile_screen.dart'
    'package:mindloop/presentation/screens/settings/settings_screen.dart' = 'package:mindloop/modules/settings/presentation/pages/settings_screen.dart'
    'package:mindloop/presentation/screens/analytics/analytics_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/analytics_screen.dart'
    'package:mindloop/presentation/screens/calendar/calendar_screen.dart' = 'package:mindloop/modules/reminder/presentation/pages/calendar_screen.dart'
    'package:mindloop/presentation/screens/auth/forgot_password_screen.dart' = 'package:mindloop/modules/auth/presentation/pages/forgot_password_screen.dart'
    'package:mindloop/presentation/screens/auth/signup_screen.dart' = 'package:mindloop/modules/auth/presentation/pages/signup_screen.dart'
    'package:mindloop/presentation/screens/auth/login_screen.dart' = 'package:mindloop/modules/auth/presentation/pages/login_screen.dart'
    'package:mindloop/presentation/screens/splash/splash_screen.dart' = 'package:mindloop/modules/onboarding/presentation/pages/splash_screen.dart'
    'package:mindloop/presentation/screens/home/home_shell.dart' = 'package:mindloop/modules/home/presentation/pages/home_shell.dart'
    'package:mindloop/presentation/screens/pfm/pfm_export_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_export_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_budget_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_budget_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_goals_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_goals_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_loans_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_loans_screen.dart'
    'package:mindloop/presentation/screens/pfm/pfm_add_sheets.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_add_sheets.dart'
    'package:mindloop/presentation/screens/pfm/pfm_utils.dart' = 'package:mindloop/modules/finance/presentation/pages/pfm_utils.dart'
    'package:mindloop/presentation/screens/budget/budget_screen.dart' = 'package:mindloop/modules/finance/presentation/pages/budget_screen.dart'
    'package:mindloop/widgets/pfm/pfm_expense_dashboard_widgets.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_expense_dashboard_widgets.dart'
    'package:mindloop/widgets/pfm/expense_reminder_feedback.dart' = 'package:mindloop/modules/finance/presentation/widgets/expense_reminder_feedback.dart'
    'package:mindloop/widgets/pfm/pfm_expense_overview.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_expense_overview.dart'
    'package:mindloop/widgets/pfm/pfm_summary_card.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_summary_card.dart'
    'package:mindloop/widgets/pfm/pfm_money_overview.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_money_overview.dart'
    'package:mindloop/widgets/pfm/pfm_form_fields.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_form_fields.dart'
    'package:mindloop/widgets/pfm/pfm_empty_data.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_empty_data.dart'
    'package:mindloop/widgets/pfm/pfm_drawer.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_drawer.dart'
    'package:mindloop/widgets/pfm/pfm_charts.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_charts.dart'
    'package:mindloop/widgets/pfm/pfm_ui_kit.dart' = 'package:mindloop/modules/finance/presentation/widgets/pfm_ui_kit.dart'
    'package:mindloop/presentation/blocs/reminder/reminder_bloc.dart' = 'package:mindloop/modules/reminder/presentation/bloc/reminder_bloc.dart'
    'package:mindloop/presentation/blocs/reminder/reminder_event.dart' = 'package:mindloop/modules/reminder/presentation/bloc/reminder_event.dart'
    'package:mindloop/presentation/blocs/reminder/reminder_state.dart' = 'package:mindloop/modules/reminder/presentation/bloc/reminder_state.dart'
    'package:mindloop/presentation/blocs/budget/budget_bloc.dart' = 'package:mindloop/modules/finance/presentation/bloc/budget_bloc.dart'
    'package:mindloop/presentation/blocs/budget/budget_event.dart' = 'package:mindloop/modules/finance/presentation/bloc/budget_event.dart'
    'package:mindloop/presentation/blocs/budget/budget_state.dart' = 'package:mindloop/modules/finance/presentation/bloc/budget_state.dart'
    'package:mindloop/presentation/blocs/pfm/pfm_bloc.dart' = 'package:mindloop/modules/finance/presentation/bloc/pfm_bloc.dart'
    'package:mindloop/presentation/blocs/pfm/pfm_event.dart' = 'package:mindloop/modules/finance/presentation/bloc/pfm_event.dart'
    'package:mindloop/presentation/blocs/pfm/pfm_state.dart' = 'package:mindloop/modules/finance/presentation/bloc/pfm_state.dart'
    'package:mindloop/presentation/blocs/auth/auth_bloc.dart' = 'package:mindloop/modules/auth/presentation/bloc/auth_bloc.dart'
    'package:mindloop/presentation/blocs/auth/auth_event.dart' = 'package:mindloop/modules/auth/presentation/bloc/auth_event.dart'
    'package:mindloop/presentation/blocs/auth/auth_state.dart' = 'package:mindloop/modules/auth/presentation/bloc/auth_state.dart'
    'package:mindloop/data/repositories/reminder_repository_impl.dart' = 'package:mindloop/modules/reminder/data/repositories/reminder_repository_impl.dart'
    'package:mindloop/data/repositories/budget_repository_impl.dart' = 'package:mindloop/modules/finance/data/repositories/budget_repository_impl.dart'
    'package:mindloop/data/repositories/pfm_repository_impl.dart' = 'package:mindloop/modules/finance/data/repositories/pfm_repository_impl.dart'
    'package:mindloop/data/repositories/auth_repository_impl.dart' = 'package:mindloop/modules/auth/data/repositories/auth_repository_impl.dart'
    'package:mindloop/data/models/budget_transaction_model.dart' = 'package:mindloop/modules/finance/data/models/budget_transaction_model.dart'
    'package:mindloop/data/models/reminder_model.dart' = 'package:mindloop/modules/reminder/data/models/reminder_model.dart'
    'package:mindloop/domain/entities/recurring_transaction_entity.dart' = 'package:mindloop/modules/finance/domain/entities/recurring_transaction_entity.dart'
    'package:mindloop/domain/entities/budget_transaction_entity.dart' = 'package:mindloop/modules/finance/domain/entities/budget_transaction_entity.dart'
    'package:mindloop/domain/entities/expense_category_entity.dart' = 'package:mindloop/modules/finance/domain/entities/expense_category_entity.dart'
    'package:mindloop/domain/entities/pfm_dashboard_snapshot.dart' = 'package:mindloop/modules/finance/domain/entities/pfm_dashboard_snapshot.dart'
    'package:mindloop/domain/entities/financial_goal_entity.dart' = 'package:mindloop/modules/finance/domain/entities/financial_goal_entity.dart'
    'package:mindloop/domain/entities/net_worth_item_entity.dart' = 'package:mindloop/modules/finance/domain/entities/net_worth_item_entity.dart'
    'package:mindloop/domain/entities/expense_budget_entity.dart' = 'package:mindloop/modules/finance/domain/entities/expense_budget_entity.dart'
    'package:mindloop/domain/entities/reminder_entity.dart' = 'package:mindloop/modules/reminder/domain/entities/reminder_entity.dart'
    'package:mindloop/domain/entities/loan_entity.dart' = 'package:mindloop/modules/finance/domain/entities/loan_entity.dart'
    'package:mindloop/domain/repositories/reminder_repository.dart' = 'package:mindloop/modules/reminder/domain/repositories/reminder_repository.dart'
    'package:mindloop/domain/repositories/budget_repository.dart' = 'package:mindloop/modules/finance/domain/repositories/budget_repository.dart'
    'package:mindloop/domain/repositories/pfm_repository.dart' = 'package:mindloop/modules/finance/domain/repositories/pfm_repository.dart'
    'package:mindloop/domain/repositories/auth_repository.dart' = 'package:mindloop/modules/auth/domain/repositories/auth_repository.dart'
    'package:mindloop/core/constants/expense_reminder_constants.dart' = 'package:mindloop/modules/finance/core/constants/expense_reminder_constants.dart'
    'package:mindloop/core/constants/reminder_categories.dart' = 'package:mindloop/modules/reminder/core/constants/reminder_categories.dart'
    'package:mindloop/core/constants/reminder_ringtones.dart' = 'package:mindloop/modules/reminder/core/constants/reminder_ringtones.dart'
    'package:mindloop/core/constants/currency_options.dart' = 'package:mindloop/modules/finance/core/constants/currency_options.dart'
    'package:mindloop/core/constants/pfm_categories.dart' = 'package:mindloop/modules/finance/core/constants/pfm_categories.dart'
    'package:mindloop/core/utils/expense_reminder_preferences.dart' = 'package:mindloop/modules/finance/core/utils/expense_reminder_preferences.dart'
    'package:mindloop/core/utils/reminder_audio_permissions.dart' = 'package:mindloop/modules/reminder/core/utils/reminder_audio_permissions.dart'
    'package:mindloop/core/utils/calculator_usage_tracker.dart' = 'package:mindloop/modules/calculator/core/utils/calculator_usage_tracker.dart'
    'package:mindloop/core/utils/pomodoro_preferences.dart' = 'package:mindloop/modules/pomodoro/core/utils/pomodoro_preferences.dart'
    'package:mindloop/core/utils/reminder_sound_player.dart' = 'package:mindloop/modules/reminder/core/utils/reminder_sound_player.dart'
    'package:mindloop/core/utils/pfm_display_helpers.dart' = 'package:mindloop/modules/finance/core/utils/pfm_display_helpers.dart'
    'package:mindloop/core/utils/currency_preferences.dart' = 'package:mindloop/modules/finance/core/utils/currency_preferences.dart'
    'package:mindloop/services/expense_reminder_alert_launcher.dart' = 'package:mindloop/modules/finance/services/expense_reminder_alert_launcher.dart'
    'package:mindloop/services/reminder_notification_sound.dart' = 'package:mindloop/modules/reminder/services/reminder_notification_sound.dart'
    'package:mindloop/services/finance_analytics_service.dart' = 'package:mindloop/modules/finance/services/finance_analytics_service.dart'
    'package:mindloop/services/finance_insights_service.dart' = 'package:mindloop/modules/finance/services/finance_insights_service.dart'
    'package:mindloop/services/expense_reminder_service.dart' = 'package:mindloop/modules/finance/services/expense_reminder_service.dart'
    'package:mindloop/services/reminder_alarm_coordinator.dart' = 'package:mindloop/modules/reminder/services/reminder_alarm_coordinator.dart'
    'package:mindloop/services/expense_tracker_service.dart' = 'package:mindloop/modules/finance/services/expense_tracker_service.dart'
    'package:mindloop/services/finance_export_service.dart' = 'package:mindloop/modules/finance/services/finance_export_service.dart'
    'package:mindloop/services/custom_ringtone_service.dart' = 'package:mindloop/modules/reminder/services/custom_ringtone_service.dart'
    'package:mindloop/services/reminder_alert_launcher.dart' = 'package:mindloop/modules/reminder/services/reminder_alert_launcher.dart'
    'package:mindloop/services/pomodoro_controller.dart' = 'package:mindloop/modules/pomodoro/services/pomodoro_controller.dart'
    'package:mindloop/services/reminder_due_watcher.dart' = 'package:mindloop/modules/reminder/services/reminder_due_watcher.dart'
    'package:mindloop/services/notification_service.dart' = 'package:mindloop/core/services/notification_service.dart'
    'package:mindloop/core/di/injection.dart' = 'package:mindloop/app/di/injection.dart'
    'package:mindloop/routes/app_router.dart' = 'package:mindloop/app/router/app_router.dart'
    'package:mindloop/widgets/keyboard_dismiss_scope.dart' = 'package:mindloop/shared/widgets/keyboard_dismiss_scope.dart'
    'package:mindloop/widgets/rigging_alarm_background.dart' = 'package:mindloop/shared/widgets/rigging_alarm_background.dart'
    'package:mindloop/widgets/coming_soon_card.dart' = 'package:mindloop/shared/widgets/coming_soon_card.dart'
    'package:mindloop/widgets/dynamic_background.dart' = 'package:mindloop/shared/widgets/dynamic_background.dart'
    'package:mindloop/widgets/mind_loop_logo.dart' = 'package:mindloop/shared/widgets/mind_loop_logo.dart'
    'package:mindloop/widgets/app_list_rows.dart' = 'package:mindloop/shared/widgets/app_list_rows.dart'
    'package:mindloop/widgets/app_feedback.dart' = 'package:mindloop/shared/widgets/app_feedback.dart'
    'package:mindloop/widgets/glass_card.dart' = 'package:mindloop/shared/widgets/glass_card.dart'
    'package:mindloop/widgets/glow_button.dart' = 'package:mindloop/shared/widgets/glow_button.dart'
    'package:mindloop/themes/calendar_ui_colors.dart' = 'package:mindloop/shared/theme/calendar_ui_colors.dart'
    'package:mindloop/themes/app_decorations.dart' = 'package:mindloop/shared/theme/app_decorations.dart'
    'package:mindloop/themes/app_colors.dart' = 'package:mindloop/shared/theme/app_colors.dart'
    'package:mindloop/themes/pfm_theme.dart' = 'package:mindloop/shared/theme/pfm_theme.dart'
    'package:mindloop/themes/app_theme.dart' = 'package:mindloop/shared/theme/app_theme.dart'
    'package:mindloop/app.dart' = 'package:mindloop/app/app.dart'
}

$dartFiles = Get-ChildItem -Path $lib -Recurse -Filter "*.dart"
$count = 0
foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $original = $content
    foreach ($key in $replacements.Keys) {
        $content = $content.Replace($key, $replacements[$key])
    }
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
        $count++
        Write-Host "Updated: $($file.FullName.Replace($lib + '\', ''))"
    }
}

# Also update test files if any
$testDir = "d:\Gayu - workspace\Mywork space\MindLoop\test"
if (Test-Path $testDir) {
    $testFiles = Get-ChildItem -Path $testDir -Recurse -Filter "*.dart"
    foreach ($file in $testFiles) {
        $content = Get-Content $file.FullName -Raw -Encoding UTF8
        $original = $content
        foreach ($key in $replacements.Keys) {
            $content = $content.Replace($key, $replacements[$key])
        }
        if ($content -ne $original) {
            Set-Content -Path $file.FullName -Value $content -Encoding UTF8 -NoNewline
            $count++
        }
    }
}

Write-Host "`nUpdated $count files."
