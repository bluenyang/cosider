CREATE TYPE "public"."file_ref_type_enum" AS ENUM('USER', 'PROJECT', 'TASK', 'WORKSPACE', 'DOCUMENT');--> statement-breakpoint
CREATE TYPE "public"."file_visibility_enum" AS ENUM('PRIVATE', 'PROJECT', 'WORKSPACE', 'PUBLIC');--> statement-breakpoint
CREATE TYPE "public"."priority_enum" AS ENUM('LOW', 'MID', 'HIGH');--> statement-breakpoint
CREATE TYPE "public"."deployment_platform" AS ENUM('AWS', 'SUPABASE', 'VERCEL', 'DOCKER', 'ON_PREMISE');--> statement-breakpoint
CREATE TYPE "public"."deployment_status" AS ENUM('SUCCESS', 'FAIL', 'IN_PROGRESS');--> statement-breakpoint
CREATE TYPE "public"."project_member_role" AS ENUM('OWNER', 'EDITOR', 'VIEWER');--> statement-breakpoint
CREATE TYPE "public"."sdlc_type_enum" AS ENUM('WATERFALL', 'PROTOTYPING', 'SPIRAL', 'SCRUM', 'KANBAN', 'HYBRID');--> statement-breakpoint
CREATE TYPE "public"."sprint_status" AS ENUM('UPCOMING', 'ACTIVE', 'DELAYED', 'CLOSED');--> statement-breakpoint
CREATE TYPE "public"."stage_action" AS ENUM('COMPLETE', 'SKIP', 'CANCEL', 'REVERT');--> statement-breakpoint
CREATE TYPE "public"."stage_status" AS ENUM('PLANNED', 'PENDING', 'IN_PROGRESS', 'COMPLETED', 'SKIPPED', 'CANCELED');--> statement-breakpoint
CREATE TYPE "public"."test_status" AS ENUM('PENDING', 'PASSED', 'FAILED');--> statement-breakpoint
CREATE TYPE "public"."user_credential_provider" AS ENUM('LOCAL', 'GOOGLE', 'GITHUB');--> statement-breakpoint
CREATE TYPE "public"."user_job_role" AS ENUM('FE_DEV', 'BE_DEV', 'PM', 'INFRA_EGN', 'DATA_EGN', 'SEC_EGN', 'ARCHITECT', 'PL', 'QA_EGN', 'FS_DEV', 'DESIGNER', 'CLIENT');--> statement-breakpoint
CREATE TYPE "public"."user_status" AS ENUM('PENDING', 'ACTIVE', 'INACTIVE', 'BANNED', 'PENDING_LEAVE', 'LEAVED');--> statement-breakpoint
CREATE TYPE "public"."workspace_member_role" AS ENUM('OWNER', 'ADMIN', 'MEMBER', 'VIEWER');--> statement-breakpoint
CREATE TYPE "public"."workspace_status" AS ENUM('ACTIVE', 'DEACTIVE', 'DELETE_PENDING', 'DELETED', 'RESTORING');--> statement-breakpoint
CREATE TYPE "public"."content_type" AS ENUM('YJS_BIN', 'MARKDOWN', 'JSON');--> statement-breakpoint
CREATE TYPE "public"."document_type" AS ENUM('REQUIREMENT', 'API_SPEC', 'ARCHITECTURE', 'RELEASE_NOTE', 'MEETING_LOG', 'GENERAL');--> statement-breakpoint
CREATE TYPE "public"."mapped_entity_type" AS ENUM('REQUIREMENT', 'TASK');--> statement-breakpoint
CREATE TYPE "public"."source_type" AS ENUM('MANUAL', 'GIT_RELEASE', 'WHITEBOARD');--> statement-breakpoint
CREATE TYPE "public"."requirement_status" AS ENUM('DRAFT', 'CONFIRMED', 'EDITING', 'OUTDATED', 'WITHHOLD');--> statement-breakpoint
CREATE TYPE "public"."requirement_type" AS ENUM('REQUIREMENT', 'EXCEPTION');--> statement-breakpoint
CREATE TYPE "public"."task_status" AS ENUM('TODO', 'IN_PROGRESS', 'DONE', 'CANCEL', 'WITHHOLD');--> statement-breakpoint
CREATE TYPE "public"."notification_type" AS ENUM('COMMENT', 'ISSUE_UPDATED', 'DOC_CHANGED', 'TASK_CHANGED', 'REQ_CHANGED', 'API_CHANGED', 'INVITED');--> statement-breakpoint
CREATE TABLE "refresh_tokens" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"token_value" uuid NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now(),
	"revoked_at" timestamp with time zone,
	CONSTRAINT "refresh_tokens_token_value_unique" UNIQUE("token_value")
);
--> statement-breakpoint
CREATE TABLE "media_files" (
	"id" uuid PRIMARY KEY NOT NULL,
	"bucket_name" varchar(50) NOT NULL,
	"object_key" text NOT NULL,
	"file_name" text NOT NULL,
	"mime_type" text NOT NULL,
	"file_size" bigint NOT NULL,
	"visibility" "file_visibility_enum" NOT NULL,
	"ref_type" "file_ref_type_enum" NOT NULL,
	"ref_id" uuid NOT NULL,
	"owner_id" uuid,
	"created_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "media_files_object_key_unique" UNIQUE("object_key")
);
--> statement-breakpoint
CREATE TABLE "project_checklists" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"stage_id" uuid,
	"task_name" varchar(100) NOT NULL,
	"is_required" boolean DEFAULT true NOT NULL,
	"is_completed" boolean DEFAULT false NOT NULL,
	"linked_document_id" uuid,
	"completed_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "project_deployments" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"version" varchar(100) NOT NULL,
	"platform" "deployment_platform" NOT NULL,
	"status" "deployment_status" NOT NULL,
	"deployer_id" uuid,
	"deployer_nickname" varchar(100),
	"deployment_url" text,
	"release_node_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "project_members" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"user_id" uuid,
	"role" "project_member_role" DEFAULT 'VIEWER' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "stage_histories" (
	"id" uuid PRIMARY KEY NOT NULL,
	"status" "stage_status" NOT NULL,
	"stage_id" uuid,
	"action" "stage_action" NOT NULL,
	"actor_id" uuid,
	"actor_nickname" varchar(100),
	"is_bypassed" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "project_stages" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"name" varchar(100) NOT NULL,
	"order_uniqueIndex" integer DEFAULT 0 NOT NULL,
	"is_required" boolean DEFAULT true NOT NULL,
	"status" "stage_status" DEFAULT 'PLANNED' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "project_task_counters" (
	"project_id" uuid PRIMARY KEY NOT NULL,
	"last_task_number" integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
CREATE TABLE "projects" (
	"id" uuid PRIMARY KEY NOT NULL,
	"workspace_id" uuid NOT NULL,
	"owner_id" uuid NOT NULL,
	"name" varchar(100) NOT NULL,
	"description" text,
	"is_public" boolean DEFAULT false NOT NULL,
	"key" varchar(20) NOT NULL,
	"logo_image_id" uuid,
	"tech_stacks" jsonb,
	"sdlc_type" "sdlc_type_enum" NOT NULL,
	"git_repo_url" varchar(255),
	"git_provider" varchar(20),
	"git_default_branch" varchar(100) DEFAULT 'main',
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "sprints" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"name" varchar(100) NOT NULL,
	"description" text,
	"asignee_id" uuid,
	"asignee_nickname" varchar(100),
	"status" "sprint_status" DEFAULT 'UPCOMING' NOT NULL,
	"start_date" timestamp with time zone NOT NULL,
	"end_date" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "test_cases" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid,
	"title" varchar(200) NOT NULL,
	"description" text,
	"priority" "priority_enum" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "test_runs" (
	"id" uuid PRIMARY KEY NOT NULL,
	"test_case_id" uuid,
	"status" "test_status" NOT NULL,
	"tester_id" uuid,
	"tester_nickname" varchar(100),
	"result_detail" text,
	"tested_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_backup_codes" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"code_hash" text NOT NULL,
	"used_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "user_credentials" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"provider" "user_credential_provider" NOT NULL,
	"provider_id" varchar(255) NOT NULL,
	"credential" text NOT NULL,
	"last_login" timestamp with time zone DEFAULT now(),
	CONSTRAINT "user_credentials_provider_id_unique" UNIQUE("provider_id")
);
--> statement-breakpoint
CREATE TABLE "user_profiles" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid,
	"email" varchar(254) NOT NULL,
	"handle" varchar(30) NOT NULL,
	"nickname" varchar(100),
	"profile_image_id" uuid,
	"job_role" "user_job_role" NOT NULL,
	"tech_stacks" jsonb,
	"updated_at" timestamp with time zone DEFAULT now(),
	"nickname_updated_at" timestamp with time zone DEFAULT now(),
	CONSTRAINT "user_profiles_email_unique" UNIQUE("email"),
	CONSTRAINT "user_profiles_handle_unique" UNIQUE("handle")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" uuid PRIMARY KEY NOT NULL,
	"status" "user_status" DEFAULT 'PENDING' NOT NULL,
	"two_factor_enabled" boolean DEFAULT false NOT NULL,
	"two_factor_secret" text,
	"created_at" timestamp with time zone DEFAULT now(),
	"deleted_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "workspace_invitations" (
	"id" uuid PRIMARY KEY NOT NULL,
	"workspace_id" uuid,
	"inviter_id" uuid,
	"target" varchar(255) NOT NULL,
	"token" text NOT NULL,
	"role" "workspace_member_role" DEFAULT 'MEMBER' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"expires_at" timestamp with time zone NOT NULL,
	"accepted_at" timestamp with time zone,
	CONSTRAINT "workspace_invitations_token_unique" UNIQUE("token")
);
--> statement-breakpoint
CREATE TABLE "workspace_members" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"workspace_id" uuid NOT NULL,
	"role" "workspace_member_role" DEFAULT 'MEMBER' NOT NULL,
	"joined_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "workspaces" (
	"id" uuid PRIMARY KEY NOT NULL,
	"owner_id" uuid NOT NULL,
	"slug" varchar(30) NOT NULL,
	"name" varchar(100) NOT NULL,
	"status" "workspace_status" DEFAULT 'ACTIVE' NOT NULL,
	"description" text,
	"logo_image_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"scheduled_delete_at" timestamp with time zone,
	"deleted_at" timestamp with time zone,
	CONSTRAINT "workspaces_slug_unique" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE "document_histories" (
	"id" uuid PRIMARY KEY NOT NULL,
	"document_id" uuid NOT NULL,
	"content" "bytea" NOT NULL,
	"version_tag" varchar(50),
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "documents" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid NOT NULL,
	"author_id" uuid,
	"author_nickname" varchar(100),
	"title" varchar(200) NOT NULL,
	"document_type" "document_type" NOT NULL,
	"content_type" "content_type" NOT NULL,
	"source_type" "source_type" NOT NULL,
	"content" "bytea",
	"content_vector" "bytea" DEFAULT '\x'::bytea,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "whiteboard_objects" (
	"entity_id" uuid PRIMARY KEY NOT NULL,
	"whiteboard_doc_id" uuid NOT NULL,
	"object_id" varchar(255) NOT NULL,
	"mapped_entity_type" "mapped_entity_type",
	"mapped_entity_id" uuid
);
--> statement-breakpoint
CREATE TABLE "requirements" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid NOT NULL,
	"document_id" uuid NOT NULL,
	"type" "requirement_type" NOT NULL,
	"requirement_code" varchar(50) NOT NULL,
	"content_text" text,
	"content_hash" varchar(64) NOT NULL,
	"status" "requirement_status" DEFAULT 'DRAFT' NOT NULL
);
--> statement-breakpoint
CREATE TABLE "requirement_task_links" (
	"requirement_id" uuid NOT NULL,
	"task_id" uuid NOT NULL,
	CONSTRAINT "requirement_task_links_requirement_id_task_id_pk" PRIMARY KEY("requirement_id","task_id")
);
--> statement-breakpoint
CREATE TABLE "task_attachments" (
	"id" uuid PRIMARY KEY NOT NULL,
	"task_id" uuid NOT NULL,
	"file_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "task_dependencies" (
	"id" uuid PRIMARY KEY NOT NULL,
	"task_id" uuid NOT NULL,
	"predecessor_task_id" uuid NOT NULL
);
--> statement-breakpoint
CREATE TABLE "tasks" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid NOT NULL,
	"task_number" integer NOT NULL,
	"assignee_id" uuid,
	"assignee_nickname" varchar(100),
	"reporter_id" uuid,
	"reporter_nickname" varchar(100),
	"linked_document_id" uuid,
	"sprint_id" uuid,
	"title" varchar(255) NOT NULL,
	"description" text,
	"status" "task_status" DEFAULT 'TODO' NOT NULL,
	"priority" "priority_enum" NOT NULL,
	"start_date" timestamp with time zone,
	"due_date" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now(),
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "api_requirement_links" (
	"api_id" uuid NOT NULL,
	"requirement_id" uuid NOT NULL,
	"sync_status" varchar(20) DEFAULT 'UPDATED',
	"last_synced_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE "api_specifications" (
	"id" uuid PRIMARY KEY NOT NULL,
	"project_id" uuid NOT NULL,
	"method" varchar(10) NOT NULL,
	"endpoint_path" varchar(255) NOT NULL,
	"summary" varchar(255),
	"request_schema" jsonb,
	"response_schema" jsonb
);
--> statement-breakpoint
CREATE TABLE "checklist_templates" (
	"id" uuid PRIMARY KEY NOT NULL,
	"sdlc_type" varchar(20) NOT NULL,
	"stage_name" varchar(100) NOT NULL,
	"task_name" varchar(200) NOT NULL,
	"is_required" boolean DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE TABLE "sdlc_templates" (
	"id" uuid PRIMARY KEY NOT NULL,
	"sdlc_type" varchar(20) NOT NULL,
	"phases" jsonb NOT NULL,
	CONSTRAINT "sdlc_templates_sdlc_type_unique" UNIQUE("sdlc_type")
);
--> statement-breakpoint
CREATE TABLE "notifications" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"type" "notification_type" NOT NULL,
	"content" text NOT NULL,
	"link_url" text,
	"is_read" boolean DEFAULT false NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_dashboard_layouts" (
	"id" uuid PRIMARY KEY NOT NULL,
	"user_id" uuid NOT NULL,
	"workspace_id" uuid,
	"layout_data" jsonb NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "git_commits" (
	"id" uuid PRIMARY KEY NOT NULL,
	"task_id" uuid NOT NULL,
	"commit_hash" varchar(40) NOT NULL,
	"message" text NOT NULL,
	"author" varchar(100) NOT NULL,
	"url" text NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "refresh_tokens" ADD CONSTRAINT "refresh_tokens_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_files" ADD CONSTRAINT "media_files_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_checklists" ADD CONSTRAINT "project_checklists_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_checklists" ADD CONSTRAINT "project_checklists_stage_id_project_stages_id_fk" FOREIGN KEY ("stage_id") REFERENCES "public"."project_stages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_deployments" ADD CONSTRAINT "project_deployments_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_deployments" ADD CONSTRAINT "project_deployments_deployer_id_users_id_fk" FOREIGN KEY ("deployer_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_members" ADD CONSTRAINT "project_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stage_histories" ADD CONSTRAINT "stage_histories_stage_id_project_stages_id_fk" FOREIGN KEY ("stage_id") REFERENCES "public"."project_stages"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "stage_histories" ADD CONSTRAINT "stage_histories_actor_id_users_id_fk" FOREIGN KEY ("actor_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_stages" ADD CONSTRAINT "project_stages_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "project_task_counters" ADD CONSTRAINT "project_task_counters_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_workspace_id_workspaces_id_fk" FOREIGN KEY ("workspace_id") REFERENCES "public"."workspaces"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "projects" ADD CONSTRAINT "projects_logo_image_id_media_files_id_fk" FOREIGN KEY ("logo_image_id") REFERENCES "public"."media_files"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "sprints" ADD CONSTRAINT "sprints_asignee_id_users_id_fk" FOREIGN KEY ("asignee_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "test_cases" ADD CONSTRAINT "test_cases_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "test_runs" ADD CONSTRAINT "test_runs_test_case_id_test_cases_id_fk" FOREIGN KEY ("test_case_id") REFERENCES "public"."test_cases"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "test_runs" ADD CONSTRAINT "test_runs_tester_id_users_id_fk" FOREIGN KEY ("tester_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_backup_codes" ADD CONSTRAINT "user_backup_codes_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_credentials" ADD CONSTRAINT "user_credentials_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_profiles" ADD CONSTRAINT "user_profiles_profile_image_id_media_files_id_fk" FOREIGN KEY ("profile_image_id") REFERENCES "public"."media_files"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspace_invitations" ADD CONSTRAINT "workspace_invitations_workspace_id_workspaces_id_fk" FOREIGN KEY ("workspace_id") REFERENCES "public"."workspaces"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspace_invitations" ADD CONSTRAINT "workspace_invitations_inviter_id_users_id_fk" FOREIGN KEY ("inviter_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspace_members" ADD CONSTRAINT "workspace_members_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspace_members" ADD CONSTRAINT "workspace_members_workspace_id_workspaces_id_fk" FOREIGN KEY ("workspace_id") REFERENCES "public"."workspaces"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_owner_id_users_id_fk" FOREIGN KEY ("owner_id") REFERENCES "public"."users"("id") ON DELETE restrict ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "workspaces" ADD CONSTRAINT "workspaces_logo_image_id_media_files_id_fk" FOREIGN KEY ("logo_image_id") REFERENCES "public"."media_files"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "document_histories" ADD CONSTRAINT "document_histories_document_id_documents_id_fk" FOREIGN KEY ("document_id") REFERENCES "public"."documents"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "documents" ADD CONSTRAINT "documents_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "documents" ADD CONSTRAINT "documents_author_id_users_id_fk" FOREIGN KEY ("author_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "whiteboard_objects" ADD CONSTRAINT "whiteboard_objects_whiteboard_doc_id_documents_id_fk" FOREIGN KEY ("whiteboard_doc_id") REFERENCES "public"."documents"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "requirements" ADD CONSTRAINT "requirements_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "requirements" ADD CONSTRAINT "requirements_document_id_documents_id_fk" FOREIGN KEY ("document_id") REFERENCES "public"."documents"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "requirement_task_links" ADD CONSTRAINT "requirement_task_links_requirement_id_requirements_id_fk" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "requirement_task_links" ADD CONSTRAINT "requirement_task_links_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_attachments" ADD CONSTRAINT "task_attachments_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_attachments" ADD CONSTRAINT "task_attachments_file_id_media_files_id_fk" FOREIGN KEY ("file_id") REFERENCES "public"."media_files"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_dependencies" ADD CONSTRAINT "task_dependencies_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "task_dependencies" ADD CONSTRAINT "task_dependencies_predecessor_task_id_tasks_id_fk" FOREIGN KEY ("predecessor_task_id") REFERENCES "public"."tasks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_assignee_id_users_id_fk" FOREIGN KEY ("assignee_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_reporter_id_users_id_fk" FOREIGN KEY ("reporter_id") REFERENCES "public"."users"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_linked_document_id_documents_id_fk" FOREIGN KEY ("linked_document_id") REFERENCES "public"."documents"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "tasks" ADD CONSTRAINT "tasks_sprint_id_sprints_id_fk" FOREIGN KEY ("sprint_id") REFERENCES "public"."sprints"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "api_requirement_links" ADD CONSTRAINT "api_requirement_links_api_id_api_specifications_id_fk" FOREIGN KEY ("api_id") REFERENCES "public"."api_specifications"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "api_requirement_links" ADD CONSTRAINT "api_requirement_links_requirement_id_requirements_id_fk" FOREIGN KEY ("requirement_id") REFERENCES "public"."requirements"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "api_specifications" ADD CONSTRAINT "api_specifications_project_id_projects_id_fk" FOREIGN KEY ("project_id") REFERENCES "public"."projects"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "notifications" ADD CONSTRAINT "notifications_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_dashboard_layouts" ADD CONSTRAINT "user_dashboard_layouts_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_dashboard_layouts" ADD CONSTRAINT "user_dashboard_layouts_workspace_id_workspaces_id_fk" FOREIGN KEY ("workspace_id") REFERENCES "public"."workspaces"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "git_commits" ADD CONSTRAINT "git_commits_task_id_tasks_id_fk" FOREIGN KEY ("task_id") REFERENCES "public"."tasks"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE UNIQUE INDEX "user_project_uidx" ON "project_members" USING btree ("user_id","project_id");--> statement-breakpoint
CREATE UNIQUE INDEX "workspace_project_key_uidx" ON "projects" USING btree ("workspace_id","key");--> statement-breakpoint
CREATE UNIQUE INDEX "workspace_member_uidx" ON "workspace_members" USING btree ("workspace_id","user_id");--> statement-breakpoint
CREATE UNIQUE INDEX "project_requirement_code_uidx" ON "requirements" USING btree ("project_id","requirement_code");--> statement-breakpoint
CREATE UNIQUE INDEX "task_dependency_uidx" ON "task_dependencies" USING btree ("task_id","predecessor_task_id");--> statement-breakpoint
CREATE UNIQUE INDEX "project_task_number_uidx" ON "tasks" USING btree ("project_id","task_number");--> statement-breakpoint
CREATE UNIQUE INDEX "api_requirement_link_uidx" ON "api_requirement_links" USING btree ("api_id","requirement_id");--> statement-breakpoint
CREATE UNIQUE INDEX "project_method_endpoint_uidx" ON "api_specifications" USING btree ("project_id","method","endpoint_path");