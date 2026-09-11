package com.syntax.wallet.data

/**
 * Parser JSON minimal (objek/array/string/angka/bool/null) — cukup untuk respons
 * JSON-RPC Ethereum. Murni, tanpa dependensi.
 */
object Json {

    fun parse(src: String): Any? {
        val p = Parser(src)
        p.skipWs()
        val v = p.parseValue()
        p.skipWs()
        require(p.i >= p.s.length) { "karakter berlebih setelah JSON" }
        return v
    }

    @Suppress("UNCHECKED_CAST")
    fun obj(v: Any?): Map<String, Any?> = v as? Map<String, Any?>
        ?: throw IllegalArgumentException("bukan objek JSON")

    fun str(v: Any?): String? = v as? String

    fun num(v: Any?): Long? = when (v) {
        is Long -> v
        is Double -> v.toLong()
        else -> null
    }

    private class Parser(val s: String) {
        var i = 0
        var depth = 0

        companion object {
            /** Batas nesting — respons rpc jahat tidak boleh menjatuhkan app (StackOverflow). */
            const val MAX_DEPTH = 64
        }

        fun skipWs() {
            while (i < s.length && s[i].isWhitespace()) i++
        }

        fun parseValue(): Any? {
            skipWs()
            require(i < s.length) { "JSON berakhir mendadak" }
            return when (s[i]) {
                '{' -> parseObject()
                '[' -> parseArray()
                '"' -> parseString()
                't' -> { expect("true"); true }
                'f' -> { expect("false"); false }
                'n' -> { expect("null"); null }
                else -> parseNumber()
            }
        }

        fun expect(word: String) {
            require(s.startsWith(word, i)) { "token tidak terduga di $i" }
            i += word.length
        }

        fun parseObject(): Map<String, Any?> {
            depth++
            require(depth <= MAX_DEPTH) { "nesting JSON terlalu dalam (>$MAX_DEPTH)" }
            try {
                i++ // {
                val out = LinkedHashMap<String, Any?>()
                skipWs()
                if (i < s.length && s[i] == '}') { i++; return out }
                while (true) {
                    skipWs()
                    require(i < s.length && s[i] == '"') { "kunci objek harus string" }
                    val key = parseString()
                    skipWs()
                    require(i < s.length && s[i] == ':') { "harus ada ':'" }
                    i++
                    out[key] = parseValue()
                    skipWs()
                    require(i < s.length) { "objek tidak ditutup" }
                    when (s[i]) {
                        ',' -> i++
                        '}' -> { i++; return out }
                        else -> throw IllegalArgumentException("harus ',' atau '}' di $i")
                    }
                }
            } finally {
                depth--
            }
        }

        fun parseArray(): List<Any?> {
            depth++
            require(depth <= MAX_DEPTH) { "nesting JSON terlalu dalam (>$MAX_DEPTH)" }
            try {
                i++ // [
                val out = ArrayList<Any?>()
                skipWs()
                if (i < s.length && s[i] == ']') { i++; return out }
                while (true) {
                    out.add(parseValue())
                    skipWs()
                    require(i < s.length) { "array tidak ditutup" }
                    when (s[i]) {
                        ',' -> i++
                        ']' -> { i++; return out }
                        else -> throw IllegalArgumentException("harus ',' atau ']' di $i")
                    }
                }
            } finally {
                depth--
            }
        }

        fun parseString(): String {
            i++ // "
            val sb = StringBuilder()
            while (true) {
                require(i < s.length) { "string tidak ditutup" }
                when (val c = s[i]) {
                    '"' -> { i++; return sb.toString() }
                    '\\' -> {
                        i++
                        require(i < s.length) { "escape tidak lengkap" }
                        when (val e = s[i]) {
                            '"' -> sb.append('"')
                            '\\' -> sb.append('\\')
                            '/' -> sb.append('/')
                            'b' -> sb.append('\b')
                            'f' -> sb.append('\u000C')
                            'n' -> sb.append('\n')
                            'r' -> sb.append('\r')
                            't' -> sb.append('\t')
                            'u' -> {
                                require(i + 4 < s.length) { "\\u tidak lengkap" }
                                val hex = s.substring(i + 1, i + 5)
                                sb.append(hex.toInt(16).toChar())
                                i += 4
                            }
                            else -> throw IllegalArgumentException("escape tidak dikenal: \\$e")
                        }
                        i++
                    }
                    else -> { sb.append(c); i++ }
                }
            }
        }

        fun parseNumber(): Any {
            val start = i
            if (i < s.length && s[i] == '-') i++
            require(i < s.length && s[i].isDigit()) { "angka tidak valid" }
            while (i < s.length && s[i].isDigit()) i++
            var isDouble = false
            if (i < s.length && s[i] == '.') {
                isDouble = true
                i++
                while (i < s.length && s[i].isDigit()) i++
            }
            if (i < s.length && (s[i] == 'e' || s[i] == 'E')) {
                isDouble = true
                i++
                if (i < s.length && (s[i] == '+' || s[i] == '-')) i++
                while (i < s.length && s[i].isDigit()) i++
            }
            val tok = s.substring(start, i)
            return if (isDouble) tok.toDouble() else (tok.toLongOrNull() ?: tok.toDouble())
        }
    }
}
