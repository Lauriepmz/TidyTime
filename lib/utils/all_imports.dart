// Import external packages
export 'package:intl/intl.dart' hide TextDirection;
export 'package:flutter/material.dart' hide RefreshCallback;
export 'package:flutter/services.dart';
export 'package:sqflite/sqflite.dart';
export 'package:table_calendar/table_calendar.dart';
export 'dart:io' ;
export 'dart:async';
export 'package:path_provider/path_provider.dart';
export 'package:flutter/cupertino.dart';
export 'package:flutter_slidable/flutter_slidable.dart' hide ConfirmDismissCallback;
export 'package:fl_chart/fl_chart.dart';
export 'package:image_picker/image_picker.dart';
export 'package:hive_flutter/hive_flutter.dart';
export 'package:flutter_bloc/flutter_bloc.dart';
export 'package:bloc/bloc.dart';
export 'package:equatable/equatable.dart';
export 'package:provider/provider.dart';
export 'package:flutter_xlider/flutter_xlider.dart';
export 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
export 'package:permission_handler/permission_handler.dart';
export 'package:fuzzywuzzy/fuzzywuzzy.dart';
export 'dart:convert';
export 'package:flutter_gen/gen_l10n/app_localizations.dart';
export 'package:flutter_localizations/flutter_localizations.dart';
export 'package:html_unescape/html_unescape.dart';

// Import project-specific utilities and helpers
export 'package:tidytime/utils/date_helper.dart';
export 'package:tidytime/utils/date_calculator.dart';
export 'package:tidytime/utils/time_helper.dart';
export 'package:tidytime/utils/task_filter_util.dart';
export 'package:tidytime/utils/time_proportion_converter.dart';
export 'package:tidytime/utils/room_translator.dart';
export 'package:tidytime/database/database_helper.dart';
export 'package:tidytime/database/init_data.dart';
export 'package:tidytime/database/models/task_model.dart';
export 'package:tidytime/database/task_details_fetcher.dart';
export 'package:tidytime/database/models/task_time_logs_model.dart';
export 'package:tidytime/database/temporary_database/cleaning_session/temporary_task_timer_log.dart';
export 'package:tidytime/database/temporary_database/task_creation_quizz/temporary_time_proportion_model.dart';
export 'package:tidytime/database/temporary_database/task_creation_quizz/temporary_time_allocation_model.dart';
export 'package:tidytime/database/temporary_database/task_creation_quizz/temporary_room_selected_model.dart';
export 'package:tidytime/database/temporary_database/task_creation_quizz/temporary_selected_tasks_model.dart';
export 'package:tidytime/database/temporary_database/task_creation_quizz/temporary_quizz_results_model.dart';

// Import components
export 'package:tidytime/components/task_management/choice_list/room_choices.dart';
export 'package:tidytime/components/task_management/variables_selector_widgets/room_selector.dart';
export 'package:tidytime/components/task_management/variables_selector_widgets/periodic_selector.dart';
export 'package:tidytime/components/task_management/choice_list/tasktype_choices.dart';
export 'package:tidytime/components/task_management/room_manager.dart';
export 'package:tidytime/components/task_management/choice_list/predefined_tasks.dart';
export 'package:tidytime/components/task_management/variables_selector_widgets/task_type_selector.dart';
export 'package:tidytime/components/task_management/variables_selector_widgets/task_name_input.dart';
export 'package:tidytime/components/task_management/variables_selector_widgets/start_date_selector.dart';
export 'package:tidytime/components/task_management/task_submit_service.dart';
export 'package:tidytime/components/agenda/agenda_task_list_widget.dart';
export 'package:tidytime/components/empty_task_container.dart';
export 'package:tidytime/components/cleaning_session_dialogs.dart';
export 'package:tidytime/components/planning_algorithm/s4_preference_ranking_widget.dart';
export 'package:tidytime/components/planning_algorithm/s3_weekly_time_allocation_page.dart';
export 'package:tidytime/components/planning_algorithm/s6_room_grouping_widget.dart';
export 'package:tidytime/components/planning_algorithm/s1_multi_room_selector.dart';
export 'package:tidytime/components/planning_algorithm/s2.2_room_task_selection_page.dart';
export 'package:tidytime/components/planning_algorithm/s5_multiple_choice_questions.dart';
export 'package:tidytime/widgets/home_page/room_list_widget.dart';
export 'package:tidytime/widgets/home_page/pie_chart_widget.dart';
export 'package:tidytime/widgets/timer/timer_display_widget.dart';
export 'package:tidytime/widgets/timer/timer_control_buttons.dart';
export 'package:tidytime/widgets/timer/full_screen_icon.dart';
export 'package:tidytime/widgets/selection_tab_bar.dart';
export 'package:tidytime/components/planning_algorithm/s2.1_room_selected_task_selection.dart';

// Import services
export 'package:tidytime/services/task_management/task_creation_service.dart';
export 'package:tidytime/services/task_management/task_modification_service.dart';
export 'package:tidytime/services/task_management/task_detail_service.dart';
export 'package:tidytime/services/task_management/task_completion_service.dart';
export 'package:tidytime/services/agenda/agenda_task_service.dart';
export 'package:tidytime/services/agenda/agenda_task_action_service.dart';
export 'package:tidytime/services/cleaning_sessions/timer_service.dart';
export 'package:tidytime/services/task_management/task_service.dart';
export 'package:tidytime/services/cleaning_sessions/task_time_logger.dart';
export 'package:tidytime/services/completion_date_log_service.dart';
export 'package:tidytime/services/bottom_sheet_service.dart';
export 'package:tidytime/services/user_settings_service.dart';

// Import handlers
export 'package:tidytime/handlers/agenda_task_list_handler.dart';
export 'package:tidytime/style/button_styles.dart';
export 'package:tidytime/style/header_styles.dart';
export 'package:tidytime/handlers/search_handler.dart';
export 'package:tidytime/handlers/task_submission_handler.dart';
export 'package:tidytime/handlers/page_navigation_mixin.dart';

//state management
export 'package:tidytime/state_management/cleaning_session/session_events.dart';
export 'package:tidytime/state_management/cleaning_session/session_bloc.dart';
export 'package:tidytime/state_management/cleaning_session/session_states.dart';
export 'package:tidytime/state_management/planning_algorithm/task_planning_bloc.dart';
export 'package:tidytime/state_management/planning_algorithm/task_planning_state.dart';
export 'package:tidytime/state_management/planning_algorithm/task_planning_event.dart';
export 'package:tidytime/state_management/planning_algorithm/hive_box_manager.dart';

export 'package:tidytime/utils/task_planification_creation/step_one.dart';
export 'package:tidytime/utils/task_planification_creation/step_two.dart';
export 'package:tidytime/utils/task_planification_creation/step_three_to_five.dart';
export 'package:tidytime/utils/task_planification_creation/distribute_by_frequency.dart';
export 'package:tidytime/utils/task_planification_creation/distribute_by_room.dart';
export 'package:tidytime/utils/task_planification_creation/distribute_by_task_type.dart';
export 'package:tidytime/utils/task_planification_creation/adjust_for_time_proportion.dart';
export 'package:tidytime/utils/task_planification_creation/step_seven.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/daily_task_processor.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/flexible_date_generator.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/daily_load_calculator.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/task_due_date_generator.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/task_scheduler.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/proximity_penalty_manager.dart';
export 'package:tidytime/utils/task_planification_creation/step_six/task_validator.dart';

// Import pages
export 'package:tidytime/pages/calendar/calendar_page.dart';
export 'package:tidytime/pages/task/task_modification_pages/edit_task_page.dart';
export 'package:tidytime/pages/home/home_page.dart';
export 'package:tidytime/pages/profil/profile_page.dart';
export 'package:tidytime/Pages/profil/profile_image_selector.dart';
export 'package:tidytime/pages/task/task_detail_pages/task_detail_page.dart';
export 'package:tidytime/pages/task/task_list_pages/task_list_page.dart';
export 'package:tidytime/pages/task/task_list_pages/all_tasks_page.dart';
export 'package:tidytime/Pages/task/custom_task_creation_pages/create_task_page.dart';
export 'package:tidytime/pages/task/task_loading_page.dart';
export 'package:tidytime/Pages/task/singular_predefined_task_creation/predefined_task_page.dart';
export 'package:tidytime/Pages/calendar/completed_today_list_widget.dart';
export 'package:tidytime/Pages/calendar/calendar_widget.dart';
export 'package:tidytime/pages/calendar/agenda_task_list_item_widget.dart';
export 'package:tidytime/Pages/home/dashboard_widgets.dart';
export 'package:tidytime/Pages/cleaning_session/cleaning_session_page.dart';
export 'package:tidytime/Pages/cleaning_session/task_check_list_widget.dart';
export 'package:tidytime/Pages/cleaning_session/floating_timer_widget.dart';
export 'package:tidytime/Pages/cleaning_session/timer_widget.dart';
export 'package:tidytime/Pages/cleaning_session/cleaning_session_transition_page.dart';
export 'package:tidytime/Pages/task/task_creation_transition_page.dart';
export 'package:tidytime/Pages/task/singular_predefined_task_creation/predefined_task_wizard_page.dart';
export 'package:tidytime/Pages/task/bulk_predefined_task_creation/task_creation_planification_quizz.dart';
export 'package:tidytime/components/main_app_bar.dart';
export 'package:tidytime/components/main_drawer.dart';
export 'package:tidytime/main.dart';
export 'package:tidytime/Pages/main_page.dart';
export 'package:tidytime/services/task_selection_mixin.dart';
export 'package:tidytime/widgets/room_selection_base.dart';
export 'package:tidytime/services/localization_service.dart';
export 'package:tidytime/utils/laguage_provider.dart';