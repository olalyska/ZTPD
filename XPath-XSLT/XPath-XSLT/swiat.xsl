<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0">
  <xsl:key name="continentByName" match="KONTYNENT" use="NAZWA"/>

  <xsl:template match='/'>
    <html>
      <head>
        <link href="swiat.css" rel="stylesheet" type="text/css"/>
      </head>
      <body>
        <table>
          <tr><th>lp</th><th>Kraj</th><th>Stolica</th></tr>
          <xsl:apply-templates select="SWIAT/KRAJE/KRAJ[@KONTYNENT=key('continentByName', 'Europe')/@ID]">
            <xsl:sort select="NAZWA"/>
          </xsl:apply-templates>
        </table>
        Liczba krajów: <xsl:value-of select="count(SWIAT/KRAJE/KRAJ[@KONTYNENT=key('continentByName', 'Europe')/@ID])"/>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*">
    <tr>
      <td><xsl:value-of select="position()"/></td>
      <td><xsl:value-of select="NAZWA"/></td>
      <td><xsl:value-of select="STOLICA"/></td>
    </tr>
  </xsl:template>
</xsl:stylesheet>