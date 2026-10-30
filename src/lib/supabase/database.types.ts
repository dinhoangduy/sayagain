export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export type Database = {
  __InternalSupabase: {
    PostgrestVersion: "14.18";
  };
  public: {
    Tables: {
      cards: {
        Row: {
          answer: string;
          audio_url: string | null;
          content_version: number;
          context: string;
          created_at: string;
          episode_id: string;
          framework: Json | null;
          id: string;
          image_url: string | null;
          level: string | null;
          question: string;
          sort_order: number;
          task: string;
          updated_at: string;
        };
        Insert: {
          answer: string;
          audio_url?: string | null;
          content_version?: number;
          context: string;
          created_at?: string;
          episode_id: string;
          framework?: Json | null;
          id: string;
          image_url?: string | null;
          level?: string | null;
          question: string;
          sort_order?: number;
          task: string;
          updated_at?: string;
        };
        Update: {
          answer?: string;
          audio_url?: string | null;
          content_version?: number;
          context?: string;
          created_at?: string;
          episode_id?: string;
          framework?: Json | null;
          id?: string;
          image_url?: string | null;
          level?: string | null;
          question?: string;
          sort_order?: number;
          task?: string;
          updated_at?: string;
        };
        Relationships: [
          {
            foreignKeyName: "cards_episode_id_fkey";
            columns: ["episode_id"];
            isOneToOne: false;
            referencedRelation: "episodes";
            referencedColumns: ["id"];
          },
        ];
      };
      episodes: {
        Row: {
          created_at: string;
          description: string;
          id: string;
          language: string;
          published_at: string | null;
          source_url: string | null;
          status: string;
          title: string;
          topic: string;
          updated_at: string;
        };
        Insert: {
          created_at?: string;
          description?: string;
          id: string;
          language?: string;
          published_at?: string | null;
          source_url?: string | null;
          status?: string;
          title: string;
          topic?: string;
          updated_at?: string;
        };
        Update: {
          created_at?: string;
          description?: string;
          id?: string;
          language?: string;
          published_at?: string | null;
          source_url?: string | null;
          status?: string;
          title?: string;
          topic?: string;
          updated_at?: string;
        };
        Relationships: [];
      };
      review_events: {
        Row: {
          card_id: string;
          created_at: string;
          event_id: string;
          prior_state: Json;
          rating: number;
          resulting_state: Json;
          reviewed_at: string;
          user_id: string;
        };
        Insert: {
          card_id: string;
          created_at?: string;
          event_id: string;
          prior_state: Json;
          rating: number;
          resulting_state: Json;
          reviewed_at?: string;
          user_id?: string;
        };
        Update: {
          card_id?: string;
          created_at?: string;
          event_id?: string;
          prior_state?: Json;
          rating?: number;
          resulting_state?: Json;
          reviewed_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "review_events_card_id_fkey";
            columns: ["card_id"];
            isOneToOne: false;
            referencedRelation: "cards";
            referencedColumns: ["id"];
          },
        ];
      };
      user_cards: {
        Row: {
          card_id: string;
          created_at: string;
          difficulty: number;
          due_at: string;
          elapsed_days: number;
          fsrs_state: number;
          id: string;
          lapses: number;
          last_review_at: string | null;
          learning_steps: number;
          reps: number;
          scheduled_days: number;
          stability: number;
          updated_at: string;
          user_id: string;
          version: number;
        };
        Insert: {
          card_id: string;
          created_at?: string;
          difficulty?: number;
          due_at?: string;
          elapsed_days?: number;
          fsrs_state?: number;
          id?: string;
          lapses?: number;
          last_review_at?: string | null;
          learning_steps?: number;
          reps?: number;
          scheduled_days?: number;
          stability?: number;
          updated_at?: string;
          user_id?: string;
          version?: number;
        };
        Update: {
          card_id?: string;
          created_at?: string;
          difficulty?: number;
          due_at?: string;
          elapsed_days?: number;
          fsrs_state?: number;
          id?: string;
          lapses?: number;
          last_review_at?: string | null;
          learning_steps?: number;
          reps?: number;
          scheduled_days?: number;
          stability?: number;
          updated_at?: string;
          user_id?: string;
          version?: number;
        };
        Relationships: [
          {
            foreignKeyName: "user_cards_card_id_fkey";
            columns: ["card_id"];
            isOneToOne: false;
            referencedRelation: "cards";
            referencedColumns: ["id"];
          },
        ];
      };
      user_episode_imports: {
        Row: {
          episode_id: string;
          id: string;
          imported_at: string;
          last_imported_at: string;
          user_id: string;
        };
        Insert: {
          episode_id: string;
          id?: string;
          imported_at?: string;
          last_imported_at?: string;
          user_id?: string;
        };
        Update: {
          episode_id?: string;
          id?: string;
          imported_at?: string;
          last_imported_at?: string;
          user_id?: string;
        };
        Relationships: [
          {
            foreignKeyName: "user_episode_imports_episode_id_fkey";
            columns: ["episode_id"];
            isOneToOne: false;
            referencedRelation: "episodes";
            referencedColumns: ["id"];
          },
        ];
      };
      user_settings: {
        Row: {
          created_at: string;
          timezone: string;
          updated_at: string;
          user_id: string;
        };
        Insert: {
          created_at?: string;
          timezone?: string;
          updated_at?: string;
          user_id?: string;
        };
        Update: {
          created_at?: string;
          timezone?: string;
          updated_at?: string;
          user_id?: string;
        };
        Relationships: [];
      };
    };
    Views: {
      [_ in never]: never;
    };
    Functions: {
      get_published_deck: {
        Args: { p_episode_id: string };
        Returns: Json;
      };
      list_published_catalog: {
        Args: Record<string, never>;
        Returns: Json;
      };
      import_episode_deck: {
        Args: { p_episode_id: string };
        Returns: Json;
      };
      sync_study_collection: {
        Args: { p_reviews: Json };
        Returns: Json;
      };
      submit_card_review: {
        Args: {
          p_card_id: string;
          p_difficulty: number;
          p_due_offset_ms: number;
          p_elapsed_days: number;
          p_event_id: string;
          p_expected_version: number;
          p_fsrs_state: number;
          p_lapses: number;
          p_learning_steps: number;
          p_rating: number;
          p_reps: number;
          p_scheduled_days: number;
          p_stability: number;
        };
        Returns: Json;
      };
    };
    Enums: {
      [_ in never]: never;
    };
    CompositeTypes: {
      [_ in never]: never;
    };
  };
};

export type EpisodeRow = Database["public"]["Tables"]["episodes"]["Row"];
export type CardRow = Database["public"]["Tables"]["cards"]["Row"];
export type UserCardRow = Database["public"]["Tables"]["user_cards"]["Row"];
export type ReviewEventRow = Database["public"]["Tables"]["review_events"]["Row"];
export type UserEpisodeImportRow =
  Database["public"]["Tables"]["user_episode_imports"]["Row"];
export type UserSettingsRow =
  Database["public"]["Tables"]["user_settings"]["Row"];

export interface ImportEpisodeDeckResult {
  episode_id: string;
  total_cards: number;
  added_count: number;
  existing_count: number;
}

export type SubmitCardReviewStatus =
  | "ok"
  | "already_applied"
  | "version_conflict";

export interface SubmitCardReviewResult {
  status: SubmitCardReviewStatus;
  server_time: string;
  current_version?: number;
  user_card: UserCardRow;
}
