import { Entity, Column, CreateDateColumn, UpdateDateColumn, Index } from 'typeorm';
import { BaseEntity } from '@app/database-postgres';
import { ConversationType } from '@app/common';

/**
 * Conversation Entity
 * 
 * Manages conversation metadata and type
 * 
 * Business Rules:
 * - DIRECT: exactly 2 members, no name required
 * - GROUP: 3-100 members, name required
 * - COMMUNITY: >100 members, name required
 * 
 * All conversation types use offset-based messaging:
 * - Offset is sequential per conversation (starts from 0)
 * - Used for ordering, pagination, and unread calculation
 * - Incremented atomically on each message
 */
@Entity('conversations')
@Index(['type'])
@Index(['createdBy'])
export class Conversation extends BaseEntity {
  @Column({
    type: 'enum',
    enum: ConversationType,
    default: ConversationType.DIRECT,
  })
  type: ConversationType;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name?: string; // Required for GROUP/COMMUNITY, null for DIRECT

  @Column({ type: 'text', nullable: true })
  description?: string;

  @Column({ name: 'avatar_url', type: 'varchar', length: 500, nullable: true })
  avatarUrl?: string;

  @Column({ name: 'member_count', type: 'int', default: 0 })
  @Index()
  memberCount: number;

  /**
   * Max offset - Sequential message counter for ALL conversation types
   * - DIRECT: offset increments on each message
   * - GROUP: offset increments on each message
   * - COMMUNITY: offset increments on each message
   * - Incremented atomically on each message
   * - Used for:
   *   1. Message ordering (ORDER BY offset)
   *   2. Pagination (after/before offset)
   *   3. Unread calculation: unread = maxOffset - lastSeenOffset
   */
  @Column({ name: 'max_offset', type: 'bigint', default: 0 })
  @Index()
  maxOffset: number;

  @Column({ name: 'created_by', type: 'uuid' })
  createdBy: string; // User ID who created

  @Column({ type: 'jsonb', nullable: true })
  metadata?: Record<string, any>; // Flexible field for future features

  @CreateDateColumn({ name: 'created_at' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at' })
  updatedAt: Date;
}
