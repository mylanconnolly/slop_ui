/*
 * Query matching shared by the combobox and command palette.
 *
 *   parseQuery('u s')        -> [{text: "u", literal: false}, {text: "s", literal: false}]
 *   parseQuery('"u s" x')    -> [{text: "u s", literal: true}, {text: "x", literal: false}]
 *
 * Unquoted tokens match a word prefix or any substring; quoted tokens match a
 * contiguous substring only. Every token must match. Diacritics are folded.
 * `match` returns null or {score, ranges} where ranges are [start, end) in
 * the original label for highlighting; higher score is a better match.
 */
export const fold = (s) => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase()

export function parseQuery(query) {
  const tokens = []
  const re = /"([^"]*)"|(\S+)/g
  let m
  while ((m = re.exec(query))) {
    if (m[1] !== undefined) { if (m[1].trim()) tokens.push({ text: fold(m[1]), literal: true }) }
    else tokens.push({ text: fold(m[2]), literal: false })
  }
  return tokens
}

/* Character offsets where words start in the folded label. */
function wordStarts(folded) {
  const starts = []
  let inWord = false
  for (let i = 0; i < folded.length; i++) {
    const isWordChar = /[\p{L}\p{N}]/u.test(folded[i])
    if (isWordChar && !inWord) starts.push(i)
    inWord = isWordChar
  }
  return starts
}

export function match(label, tokens, extra = "") {
  if (tokens.length === 0) return { score: 0, ranges: [] }
  const folded = fold(label)
  const haystack = extra ? folded + " " + fold(extra) : folded
  const starts = wordStarts(folded)
  const literalIn = (needle) => haystack.indexOf(needle)
  let score = 0
  const ranges = []

  for (const token of tokens) {
    if (token.literal) {
      const at = literalIn(token.text)
      if (at === -1) return null
      if (at < folded.length) ranges.push([at, Math.min(at + token.text.length, folded.length)])
      score += 3
      continue
    }
    const prefixAt = starts.find((s) => folded.startsWith(token.text, s))
    if (prefixAt !== undefined) {
      ranges.push([prefixAt, prefixAt + token.text.length])
      score += prefixAt === 0 ? 4 : 3
      continue
    }
    // Single characters only ever match word starts; as substrings they're noise.
    const short = token.text.length < 2
    if (!short) {
      const at = folded.indexOf(token.text)
      if (at !== -1) {
        ranges.push([at, at + token.text.length])
        score += 1
        continue
      }
    }
    // Keywords/hints: word-prefix for short tokens, substring otherwise. No highlight.
    if (extra) {
      const extraFolded = fold(extra)
      const ok = short ? wordStarts(extraFolded).some((i) => extraFolded.startsWith(token.text, i)) : extraFolded.includes(token.text)
      if (ok) { score += 0.5; continue }
    }
    return null
  }
  return { score, ranges: mergeRanges(ranges) }
}

function mergeRanges(ranges) {
  const sorted = [...ranges].sort((a, b) => a[0] - b[0])
  const out = []
  for (const r of sorted) {
    const last = out.at(-1)
    if (last && r[0] <= last[1]) last[1] = Math.max(last[1], r[1])
    else out.push([...r])
  }
  return out
}

/* Build child nodes for `text` with <mark> around each range (offsets in the original text). */
export function highlightNodes(text, ranges) {
  const nodes = []
  let i = 0
  for (const [s, e] of ranges) {
    if (s > i) nodes.push(text.slice(i, s))
    const mark = document.createElement("mark")
    mark.textContent = text.slice(s, e)
    nodes.push(mark)
    i = e
  }
  if (i < text.length) nodes.push(text.slice(i))
  return nodes
}
