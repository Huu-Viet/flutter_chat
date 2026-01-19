import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  Index,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { Message } from './message.entity';

export enum MessageReceiptStatus {
  DELIVERED = 'delivered',
  READ = 'read',
}

/**
 * Message Receipt Entity
 * 
 * Tracks delivery and read status for each message per user.
 * 
 * Use Cases:
 * - Show checkmarks: sent (), delivered (), read ()
 * - Count unread messages per conversation
 * - Show "read by X users" in group chats
 * - Track when each member read the message
 */
@Entity('message_receipts')
@Index(['messageId', 'userId'], { unique: true })
@Index(['userId', 'status'])
export class MessageReceipt {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'message_id', type: 'uuid' })
  @Index()
  messageId: string;

  @Column({ name: 'user_id', type: 'varchar', length: 255 })
  @Index()
  userId: string;

  @Column({
    type: 'varchar',
    length: 20,
    enum: MessageReceiptStatus,
  })
  @Index()
  status: MessageReceiptStatus;

  @Column({ name: 'delivered_at', type: 'timestamp', nullable: true })
  deliveredAt: Date | null;

  @Column({ name: 'read_at', type: 'timestamp', nullable: true })
  @Index()
  readAt: Date | null;

  @CreateDateColumn({ name: 'created_at', type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamp' })
  updatedAt: Date;

  // Optional: Relation to Message
  @ManyToOne(() => Message, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'message_id' })
  message?: Message;
}
