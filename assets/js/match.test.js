import { test } from "node:test"
import assert from "node:assert/strict"
import { parseQuery, match } from "./match.js"

const hit = (label, q, extra) => match(label, parseQuery(q), extra)

test("initials match word prefixes in order-insensitive fashion", () => {
  assert.ok(hit("United States", "u s"))
  assert.ok(hit("United States", "s u"))
  assert.equal(hit("United States", "u x"), null)
  // single letters never match as substrings
  assert.equal(hit("Australia", "u s"), null)
  assert.equal(hit("South Africa", "u s"), null)
})

test("prefix and substring both match, prefix scores higher", () => {
  const prefix = hit("United States", "uni")
  const sub = hit("United States", "gdom") // no
  assert.ok(prefix)
  assert.equal(sub, null)
  const kingdom = hit("United Kingdom", "gdom")
  assert.ok(kingdom)
  assert.ok(prefix.score > kingdom.score)
})

test("quoted phrases are literal", () => {
  assert.equal(hit("United States", '"u s"'), null)
  assert.ok(hit("Menu Settings", '"u s"'))
  assert.ok(hit("United States", '"ted st"'))
})

test("diacritics fold", () => {
  assert.ok(hit("São Paulo", "sao"))
  assert.deepEqual(hit("São Paulo", "sao").ranges, [[0, 3]])
})

test("ranges cover each matched token and merge overlaps", () => {
  assert.deepEqual(hit("United States", "u s").ranges, [[0, 1], [7, 8]])
  assert.deepEqual(hit("United States", "unit ted").ranges, [[0, 6]])
})

test("keywords count for matching but not highlighting", () => {
  const r = hit("New project", "create", "create add")
  assert.ok(r)
  assert.deepEqual(r.ranges, [])
  assert.ok(hit("New project", "a", "create add"))
  assert.equal(hit("New project", "d", "create add"), null)
})

test("empty query matches everything with zero score", () => {
  assert.deepEqual(hit("Anything", ""), { score: 0, ranges: [] })
})
