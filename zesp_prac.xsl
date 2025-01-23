<?xml version="1.0" encoding="UTF-8"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
    <xsl:template match="/">
        <html>
            <body>
                <h1> Zespoły: </h1>
                <ol>
                    <xsl:apply-templates select="ZESPOLY/ROW" mode="list"/>
                </ol>
                <xsl:apply-templates select="ZESPOLY/ROW" mode="teams_details"/>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="ROW" mode="teams_details">
        <li><a href='#{ID_ZESP}'><xsl:apply-templates select="NAZWA"/></a></li>
    </xsl:template>

    <xsl:template match="ROW" mode="employees">
        <!--ZAD 9 link -->
        <h4 id="{ID_ZESP}">NAZWA: <xsl:value-of select="NAZWA"/></h4>
        <h4 id="{ID_ZESP}">ADRES: <xsl:value-of select="ADRES"/></h4>
        <!--ZAD 14-->
        <xsl:if test="count(PRACOWNICY/ROW)>0">
            <!--ZAD 8-->
            <table border="1">
                <tr>
                    <th>Nazwisko</th>
                    <th>Etat</th>
                    <th>Zatrudniony</th>
                    <th>Płaca pod.</th>
                    <th>Szef</th>
                </tr>
                <xsl:apply-templates select="PRACOWNICY/ROW" mode="list">
                    <xsl:sort select="NAZWISKO"/>
                </xsl:apply-templates>
            </table>
        </xsl:if>
        <p>Liczba pracowników: <xsl:value-of select="count(PRACOWNICY/ROW)"/></p>
    </xsl:template>

    <xsl:template match="PRACOWNICY/ROW" mode="list">
        <tr>
            <td><xsl:value-of select="NAZWISKO"/></td>
            <td><xsl:value-of select="ETAT"/></td>
            <td><xsl:value-of select="ZATRUDNIONY"/></td>
            <td><xsl:value-of select="PLACA_POD"/></td>
            <td>
                <xsl:choose>
                    <xsl:when test="ID_SZEFA">
                        <xsl:value-of select="//PRACOWNICY/ROW[ID_PRAC = current()/ID_SZEFA]/NAZWISKO"/>
                    </xsl:when>
                    <xsl:otherwise>BRAK</xsl:otherwise>
                </xsl:choose>
            </td>
        </tr>
    </xsl:template>

</xsl:stylesheet>
