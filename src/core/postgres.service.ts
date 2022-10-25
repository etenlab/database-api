import { Injectable } from "@nestjs/common"
import { Pool } from "pg"

// await client.connect()
// const res = await client.query('SELECT $1::text as message', ['Hello world!'])
// console.log(res.rows[0].message) // Hello world!
// await client.end()


@Injectable()
export class PostgresService {
  readonly pool = new Pool({
    user: process.env.DB_USERNAME,
    host: process.env.DB_HOST,
    database: process.env.DB_DATABASE,
    password: process.env.DB_PASSWORD,
    port: +process.env.DB_PORT!,
  })
}