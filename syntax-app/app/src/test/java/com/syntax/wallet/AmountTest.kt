package com.syntax.wallet

import com.syntax.wallet.util.Amount
import java.math.BigInteger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class AmountTest {

    @Test
    fun `parse ether ke wei`() {
        assertEquals(
            BigInteger.TEN.pow(18),
            Amount.parseEther("1")
        )
        assertEquals(
            BigInteger("10000000000000000"),
            Amount.parseEther("0.01")
        )
        assertEquals(
            BigInteger("1234500000000000000"),
            Amount.parseEther("1.2345")
        )
    }

    @Test
    fun `parse ether menolak input jahat`() {
        assertNull(Amount.parseEther(""))
        assertNull(Amount.parseEther("-1"))
        assertNull(Amount.parseEther("1.2.3"))
        assertNull(Amount.parseEther("abc"))
        assertNull(Amount.parseEther("0.0000000000000000001")) // > 18 desimal
    }

    @Test
    fun `format wei ke ether`() {
        assertEquals("1", Amount.formatWei(BigInteger.TEN.pow(18)))
        assertEquals("0.01", Amount.formatWei(BigInteger("10000000000000000")))
        assertEquals("1.2345", Amount.formatWei(BigInteger("1234500000000000000")))
        assertEquals("0", Amount.formatWei(BigInteger.ZERO))
    }
}
