import { Entity, Column, Index } from 'typeorm';
import { TimestampedEntity } from '@app/database-postgres';

/**
 * User Entity - Domain Model
 * Represents a user in the system following Domain-Driven Design
 * Extends TimestampedEntity from shared database module
 * 
 * Authentication Methods:
 * - Email + Password (email required)
 * - Phone + OTP (email optional, uses phone.local placeholder)
 * 
 * Users can have multiple authentication methods linked to the same account
 */
@Entity('users')
@Index(['keycloakId'], { unique: true })
@Index(['email'], { unique: true, where: "email NOT LIKE '%@phone.local'" })
@Index(['phone'], { unique: true, where: "phone IS NOT NULL" })
export class User extends TimestampedEntity {
  /**
   * Keycloak User ID - Links to authentication provider
   */
  @Column({ name: 'keycloak_id', unique: true })
  keycloakId: string;

  /**
   * Email - Optional for phone-only registrations
   * Phone-only users get placeholder email: +phonenumber@phone.local
   */
  @Column({ unique: true })
  email: string;

  @Column()
  username: string;

  @Column({ name: 'first_name', nullable: true })
  firstName?: string;

  @Column({ name: 'last_name', nullable: true })
  lastName?: string;

  /**
   * Phone number in E.164 format (e.g., +84901234567)
   */
  @Column({ nullable: true, unique: true })
  phone?: string;

  @Column({ name: 'avatar_url', nullable: true })
  avatarUrl?: string;

  /**
   * Domain Method: Get full name of the user
   */
  getFullName(): string {
    if (this.firstName && this.lastName) {
      return `${this.firstName} ${this.lastName}`;
    }
    return this.username;
  }

  /**
   * Domain Method: Check if user profile is complete
   */
  isProfileComplete(): boolean {
    return !!(
      this.firstName &&
      this.lastName &&
      this.phone
    );
  }
}
