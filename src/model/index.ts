/**
 * All entitites are exported from here for the next reasons:
 * - to make it easier to synchronize them across different repos
 * - to make it easier to generate entities from the database
 * 
 * Use this command to pull new entities from the database:
 * npx typeorm-model-generator -h <host> -d <database> -p [port] -u <user> -x
[password] -e [engine] -o ./src/model/entities
 */

import { ProgressBibleLanguageDetail } from './progress_bible_language_detail.entity';
import { Node } from './entities/Nodes';
import { NodePropertyKey } from './entities/NodePropertyKeys';
import { Relationship } from './entities/Relationships';
import { NodeType } from './entities/NodeTypes';
import { NodePropertyValue } from './entities/NodePropertyValues';
import { RelationshipPropertyKey } from './entities/RelationshipPropertyKeys';
import { RelationshipPropertyValue } from './entities/RelationshipPropertyValues';
import { RelationshipType } from './entities/RelationshipTypes';

export const entities = [
  Node,
  NodeType,
  NodePropertyKey,
  Relationship,
  NodePropertyValue,
  RelationshipPropertyKey,
  RelationshipPropertyValue,
  RelationshipType,
  ProgressBibleLanguageDetail,
];

export {
  Node,
  NodeType,
  NodePropertyKey,
  Relationship,
  NodePropertyValue,
  RelationshipPropertyKey,
  RelationshipPropertyValue,
  RelationshipType,
  ProgressBibleLanguageDetail,
};

export default entities;
