import { Schema, Prop, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';
import { MediaType, MediaStatus } from '../../constants/media.constants';

export type MediaObjectDocument = MediaObject & Document;

export interface MediaVariant {
  name: string; // thumb, preview, poster, mp4_720p, mp4_360p, hls
  key: string; // MinIO object key
  width?: number;
  height?: number;
  sizeBytes?: number;
  mime?: string;
  duration?: number; // For video segments
}

export interface MediaMetadata {
  width?: number;
  height?: number;
  duration?: number; // For video/audio in seconds
  bitrate?: number;
  codec?: string;
  format?: string;
  filename?: string;
  errorReason?: string;
  [key: string]: any;
}

@Schema({ timestamps: true, collection: 'media_objects' })
export class MediaObject {
  @Prop({ required: true })
  id: string;

  @Prop({ required: true, index: true })
  ownerId: string;

  @Prop({ required: true, type: String, enum: MediaType })
  type: MediaType;

  @Prop({ required: true })
  mimeType: string;

  @Prop({ required: true })
  size: number;

  @Prop({ required: true })
  url: string;

  @Prop({ type: [Object], default: [] })
  variants: MediaVariant[];

  @Prop()
  thumbnailUrl?: string;

  @Prop()
  checksum?: string; // MD5 or SHA256 hash for integrity verification

  @Prop()
  checksumAlgorithm?: string; // 'md5' | 'sha256'

  @Prop({ type: Object, default: {} })
  meta: MediaMetadata;

  @Prop({ required: true, type: String, enum: MediaStatus, default: MediaStatus.CREATED })
  status: MediaStatus;

  @Prop()
  expiresAt?: Date;

  createdAt: Date;
  updatedAt: Date;
}

export const MediaObjectSchema = SchemaFactory.createForClass(MediaObject);

// Indexes
MediaObjectSchema.index({ ownerId: 1, createdAt: -1 });
MediaObjectSchema.index({ status: 1 });
MediaObjectSchema.index({ expiresAt: 1 }, { sparse: true });
