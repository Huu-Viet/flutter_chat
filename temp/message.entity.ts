import { Entity, Column, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { BaseEntity } from '@app/database-postgres';

/**
 * Message Entity - Phase 3
 * 
 * Read-only storage for messages
 * Written by MessageStore consumer, read by API
 * 
 * All messages have offset for ordering and pagination
 */
@Entity('messages')
@Index(['conversationId', 'createdAt'])
@Index(['senderId'])
export class Message extends BaseEntity {
  @Column({ name: 'conversation_id' })
  @Index()
  conversationId: string;

  @Column({ name: 'sender_id' })
  senderId: string;

  @Column({ type: 'text' })
  content: string;

  @Column({ type: 'varchar', length: 50, default: 'text' })
  type: string; // 'text', 'image', 'file', 'audio', 'video'

  /**
   * Offset field for ALL conversations
   * - Sequential number assigned by MessageStore on persist
   * - Unique within each conversation (per conversationId)
   * - Used for:
   *   1. Message ordering (ORDER BY offset ASC)
   *   2. Pagination (after/before offset)
   *   3. Unread calculation
   * - Assigned atomically via Conversation.maxOffset increment
   */
  @Column({ type: 'bigint' })
  @Index()
  offset: number;

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>;

  /**
   * Flag for message requests (DIRECT conversation with strangers)
   * - true: Message from stranger (not friends, receiver hasn't replied)
   * - false: Normal inbox message
   * - Used for UI to display "Message Requests" folder
   */
  @Column({ name: 'is_message_request', default: false })
  @Index()
  isMessageRequest: boolean;

  @Column({ name: 'is_edited', default: false })
  isEdited: boolean;

  @Column({ name: 'edited_at', type: 'timestamp', nullable: true })
  editedAt?: Date;

  @Column({ name: 'is_deleted', default: false })
  isDeleted: boolean;

  @Column({ name: 'deleted_at', type: 'timestamp', nullable: true })
  deletedAt?: Date;

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
