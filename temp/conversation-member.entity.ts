import { Entity, Column, CreateDateColumn, Index, PrimaryColumn } from 'typeorm';

/**
 * Conversation Member Entity
 * 
 * Tracks membership in conversations
 * Composite PK: (conversation_id, user_id)
 */
@Entity('conversation_members')
@Index(['conversationId', 'userId'], { unique: true })
@Index(['userId'])
export class ConversationMember {
  @PrimaryColumn({ name: 'conversation_id', type: 'uuid' })
  conversationId: string;

  @PrimaryColumn({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({
    type: 'enum',
    enum: ['owner', 'admin', 'member'],
    default: 'member',
  })
  role: 'owner' | 'admin' | 'member';

  @CreateDateColumn({ name: 'joined_at' })
  joinedAt: Date;

  /**
   * Last seen offset for unread tracking
   * - Updated when user fetches messages
   * - Used for unread calculation (maxOffset - lastSeenOffset)
   */
  @Column({ name: 'last_seen_offset', type: 'bigint', nullable: true })
  lastSeenOffset?: number;
}
