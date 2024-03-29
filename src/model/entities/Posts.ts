import {
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  OneToMany,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Users } from './Users';
import { Discussions } from './Discussions';
import { Reactions } from './Reactions';
import { RelationshipPostFile } from './RelationshipPostFile';

@Entity('posts', { schema: 'admin' })
export class Posts {
  @Column('timestamp without time zone', {
    name: 'created_at',
    default: () => 'now()',
  })
  createdAt: Date;

  @PrimaryGeneratedColumn({ type: 'integer', name: 'id' })
  id: number;

  @Column('character varying', { name: 'quill_text' })
  quillText: string;

  @Column('character varying', { name: 'plain_text' })
  plainText: string;

  @Column('character varying', { name: 'postgres_language' })
  postgresLanguage: string;

  @Column('boolean', { name: 'is_edited', default: () => 'false' })
  isEdited: boolean;

  @Column('integer', { name: 'reply_id', nullable: true })
  replyId: number | null;

  @ManyToOne(() => Users, (users) => users.posts, { onDelete: 'CASCADE' })
  @JoinColumn([{ name: 'user_id', referencedColumnName: 'id' }])
  user: Users;

  @ManyToOne(() => Discussions, (discussions) => discussions.posts, {
    onDelete: 'CASCADE',
  })
  @JoinColumn([{ name: 'discussion_id', referencedColumnName: 'id' }])
  discussion: Discussions;

  @OneToMany(() => Reactions, (reactions) => reactions.post)
  reactions: Reactions[];

  @OneToMany(
    () => RelationshipPostFile,
    (relationshipPostFile) => relationshipPostFile.post,
  )
  relationshipPostFiles: RelationshipPostFile[];
}
