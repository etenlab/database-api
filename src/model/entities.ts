/**
 * All entitites are exported from here for the next reasons:
 * - to make it easier to synchronize them across different repos
 * - to make it easier to generate entities from the database
 *
 * Use this command to pull new entities from the database:
 * npx typeorm-model-generator -h postgres -d eil -u postgres -x example -e postgres -o ./src/model
 */

import { Users } from './entities/Users';
import { Avatars } from './entities/Avatars';
import { AvatarsHistory } from './entities/AvatarsHistory';
import { EmailTokens } from './entities/EmailTokens';
import { Posts } from './entities/Posts';
import { Discussions } from './entities/Discussions';
import { Reactions } from './entities/Reactions';
import { RelationshipPostFile } from './entities/RelationshipPostFile';
import { ResetTokens } from './entities/ResetTokens';
import { Tokens } from './entities/Tokens';
import { WebsocketSessions } from './entities/WebsocketSessions';
import { Files } from './entities/Files';

export const entities = [
  Users,
  Avatars,
  AvatarsHistory,
  EmailTokens,
  Posts,
  Reactions,
  ResetTokens,
  Tokens,
  WebsocketSessions,
  RelationshipPostFile,
  Discussions,
  Files,
];

export {
  Users,
  Avatars,
  AvatarsHistory,
  EmailTokens,
  Posts,
  Reactions,
  ResetTokens,
  Tokens,
  WebsocketSessions,
  RelationshipPostFile,
  Discussions,
  Files,
};

export default entities;
