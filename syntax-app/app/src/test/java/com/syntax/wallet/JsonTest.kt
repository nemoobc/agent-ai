package com.syntax.wallet

import com.syntax.wallet.data.Json
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class JsonTest {

    @Test
    fun `respons rpc sederhana`() {
        val v = Json.parse("""{"jsonrpc":"2.0","id":1,"result":"0x1234"}""")
        val obj = Json.obj(v)
        assertEquals("2.0", obj["jsonrpc"])
        assertEquals(1L, Json.num(obj["id"]))
        assertEquals("0x1234", Json.str(obj["result"]))
    }

    @Test
    fun `error rpc`() {
        val v = Json.parse("""{"jsonrpc":"2.0","id":1,"error":{"code":-32000,"message":"nonce too low"}}""")
        val obj = Json.obj(v)
        val err = obj["error"] as Map<*, *>
        assertEquals("nonce too low", err["message"])
    }

    @Test
    fun `nested objek array`() {
        val v = Json.parse("""{"a":[1,{"b":[true,false,null]}],"c":"x"}""")
        val obj = Json.obj(v)
        val a = obj["a"] as List<*>
        assertEquals(1L, a[0])
        val inner = a[1] as Map<*, *>
        val b = inner["b"] as List<*>
        assertEquals(true, b[0])
        assertEquals(false, b[1])
        assertNull(b[2])
        assertEquals("x", obj["c"])
    }

    @Test
    fun `escape string`() {
        val v = Json.parse("""{"s":"a\"b\\c\/d\be\ff\ng\rh\tiA"}""")
        assertEquals("a\"b\\c/d\u0008e\u000Cf\ng\rh\tiA", Json.obj(v)["s"])
    }

    @Test
    fun `unicode escape`() {
        val v = Json.parse("""{"u":"\u0041\u00e9"}""")
        assertEquals("Aé", Json.obj(v)["u"])
    }

    @Test
    fun `angka besar tetap Long sampai batas`() {
        // JSON-RPC mengirim nilai besar sebagai string hex ("0x…"),
        // tapi angka desimal sampai Long.MAX_VALUE harus tetap Long.
        val v = Json.parse("""{"n":9223372036854775807}""")
        assertEquals(9223372036854775807L, Json.num(Json.obj(v)["n"]))
    }

    @Test
    fun `angka di atas Long jadi Double`() {
        val v = Json.parse("""{"n":9223372036854775808}""")
        assertEquals(9.223372036854776E18, Json.obj(v)["n"])
    }

    @Test
    fun `angka desimal jadi Double`() {
        val v = Json.parse("""{"d":1.5,"e":1e3}""")
        val obj = Json.obj(v)
        assertEquals(1.5, obj["d"])
        assertEquals(1000.0, obj["e"])
    }

    @Test
    fun `whitespace longgar`() {
        val v = Json.parse("  { \"a\" : [ 1 , 2 ] }  ")
        assertEquals(2, (Json.obj(v)["a"] as List<*>).size)
    }

    @Test(expected = IllegalArgumentException::class)
    fun `karakter berlebih ditolak`() {
        Json.parse("""{"a":1} x""")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `objek tidak ditutup`() {
        Json.parse("""{"a":1""")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `kunci non-string ditolak`() {
        Json.parse("""{1:2}""")
    }

    @Test(expected = IllegalArgumentException::class)
    fun `nesting melebihi 64 ditolak — anti stack overflow`() {
        val deep = "[".repeat(100) + "]".repeat(100)
        Json.parse(deep)
    }

    @Test
    fun `nesting 64 masih ok`() {
        val deep = "[".repeat(64) + "]".repeat(64)
        val v = Json.parse(deep)
        assertTrue(v is List<*>)
    }
}
