<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:office="urn:oasis:names:tc:opendocument:xmlns:office:1.0" xmlns:style="urn:oasis:names:tc:opendocument:xmlns:style:1.0" xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0" xmlns:table="urn:oasis:names:tc:opendocument:xmlns:table:1.0" xmlns:draw="urn:oasis:names:tc:opendocument:xmlns:drawing:1.0" xmlns:fo="urn:oasis:names:tc:opendocument:xmlns:xsl-fo-compatible:1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:meta="urn:oasis:names:tc:opendocument:xmlns:meta:1.0" xmlns:number="urn:oasis:names:tc:opendocument:xmlns:datastyle:1.0" xmlns:svg="urn:oasis:names:tc:opendocument:xmlns:svg-compatible:1.0" xmlns:chart="urn:oasis:names:tc:opendocument:xmlns:chart:1.0" xmlns:dr3d="urn:oasis:names:tc:opendocument:xmlns:dr3d:1.0" xmlns:math="http://www.w3.org/1998/Math/MathML" xmlns:form="urn:oasis:names:tc:opendocument:xmlns:form:1.0" xmlns:script="urn:oasis:names:tc:opendocument:xmlns:script:1.0" xmlns:ooo="http://openoffice.org/2004/office" xmlns:ooow="http://openoffice.org/2004/writer" xmlns:oooc="http://openoffice.org/2004/calc" xmlns:dom="http://www.w3.org/2001/xml-events" xmlns:xforms="http://www.w3.org/2002/xforms" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:field="urn:openoffice:names:experimental:ooxml-odf-interop:xmlns:field:1.0" xmlns:erb="http://something" office:version="1.1" version="2.0">

<xsl:output method="text" encoding="UTF-8" media-type="text/plain" use-character-maps="cm1"/>

<xsl:character-map name="cm1">
  <xsl:output-character character="’" string="'" />
  <xsl:output-character character="&#160;" string=" "/>   
  <xsl:output-character character="&#233;" string="\'e"/> <!-- é -->
  <xsl:output-character character="ô" string="&amp;#244;"/>
  <xsl:output-character character="&#8212;" string="--"/>
  <xsl:output-character character="…" string="\ldots{}" />
</xsl:character-map>

<xsl:function name="erb:is-span-code" as="xs:boolean">
  <xsl:param name="context-node" />
  <xsl:variable name="span-style-name" select="$context-node/@text:style-name" />
  <xsl:variable name="text-underline-style" select="$context-node/ancestor::office:document-content/office:automatic-styles/style:style[@style:name=$span-style-name]/style:text-properties/@style:text-underline-style" />
  <xsl:value-of select="$text-underline-style !='' or erb:textStyleInheritsFrom($context-node,'|CD1|C1|')" />
</xsl:function>

<xsl:function name="erb:is-span-footnote" as="xs:boolean">
  <xsl:param name="context-node" />
  <xsl:variable name="span-style-name" select="$context-node/@text:style-name" />
  <xsl:variable name="font-position" select="$context-node/ancestor::office:document-content/office:automatic-styles/style:style[@style:name=$span-style-name]/style:text-properties/@style:text-position" />
  <xsl:value-of select="erb:textStyleInheritsFrom($context-node,'|Footnote_20_Symbol|') or contains($font-position,'super')" />
</xsl:function>

<xsl:function name="erb:is-span-bold" as="xs:boolean">
  <xsl:param name="context-node" />
  <xsl:variable name="span-style-name" select="$context-node/@text:style-name" />
  <xsl:variable name="font-name" select="$context-node/ancestor::office:document-content/office:automatic-styles/style:style[@style:name=$span-style-name]/style:text-properties/@style:font-name" />
  <xsl:value-of select="$font-name='AGaramond Semibold'" />
</xsl:function>

<xsl:function name="erb:containsIfNotBlank" as="xs:boolean">
  <xsl:param name="containee" />
  <xsl:param name="text" />
  <xsl:value-of select="$containee!='' and $text!='' and contains($containee, $text)" />
</xsl:function>

<xsl:function name="erb:textStyleInheritsFrom" as="xs:boolean">
  <xsl:param name="context-node" />
  <xsl:param name="inheritable-list" />
  <xsl:variable name="text-style-name" select="concat('|',$context-node/@text:style-name,'|')" />
  <xsl:variable name="ancestor-style" select="concat('|',erb:getAncestorStyle($context-node),'|')" />
  <xsl:value-of select="erb:containsIfNotBlank($inheritable-list, $ancestor-style) or erb:containsIfNotBlank($inheritable-list, $text-style-name)" />
</xsl:function>

<xsl:function name="erb:getAncestorStyle">
  <xsl:param name="context-node" />
  <xsl:variable name="text-style-name" select="$context-node/@text:style-name" />
  <xsl:value-of select="$context-node/ancestor::office:document-content/office:automatic-styles/style:style[@style:name=$text-style-name]/@style:parent-style-name" />
</xsl:function>


<!-- Document Root -->
<xsl:template match="/office:document-content/office:body/office:text">
  <xsl:apply-templates />
</xsl:template>

<!-- nodes whose contents we're skipping entirely -->
<xsl:template match="office:forms" />
<xsl:template match="text:tracked-changes" />
<xsl:template match="text:sequence-decls" />
<xsl:template match="text:table-of-content" />

<xsl:template match="text:span">
  <xsl:choose>
    <xsl:when test="erb:is-span-bold(.)">
       <xsl:text>\textbf{</xsl:text><xsl:apply-templates /><xsl:text>}</xsl:text>
     </xsl:when>
     <xsl:when test="erb:is-span-code(.)">
       <xsl:call-template name="inline-code-samples" />
     </xsl:when>
     <xsl:when test="erb:is-span-footnote(.)">
       <xsl:call-template name="footnote-callout" />
     </xsl:when>
    <xsl:otherwise>
      <xsl:apply-templates />
      <!-- <xsl:text>[uncaughttext:span</xsl:text>:<xsl:value-of select="@text:style-name" /><xsl:text>]</xsl:text> -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="footnote-callout">
  <xsl:text>footnote\#[</xsl:text><xsl:apply-templates /><xsl:text>]</xsl:text>
</xsl:template>

<xsl:variable name="block-code-style-names" select="'|LCX|LC|LC2|LX|LH|CDT1|CDT|CDTX|C1|C2|C1_20_Tip|C2_20_Tip|CDT2b|'" />
<xsl:variable name="bullet-list-style-names" select="'|BL|BL1|BLX|BX|UL|'" />
<xsl:variable name="table-style-names" select="'|TB|TBX|TH|TC|TB|TB1|TX|'" />
<xsl:variable name="numbered-list-style-names" select="'|NL|NL1|NX|NLX|NLX2|FTN|FTNx|Comment_20_Text|'" />
<xsl:variable name="aside-style-names" select="'|TIH|TIX|TI|'" />

<xsl:template match="text:p">
  <xsl:choose>
    <xsl:when test="erb:textStyleInheritsFrom(.,'|HA|')" /> <!-- Chapter X Heading -->
    <xsl:when test="erb:textStyleInheritsFrom(.,'|HB|')">
      <xsl:call-template name="chapter-heading" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,'|HC|')">
      <xsl:call-template name="section-heading" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,'|HD|')">
      <xsl:call-template name="sub-section-heading" />
    </xsl:when>    
    <xsl:when test="erb:textStyleInheritsFrom(.,'|HE|SH|')">
      <xsl:call-template name="sub-sub-section-heading" />
    </xsl:when>    
    <xsl:when test="erb:textStyleInheritsFrom(.,'|EX|')">
      <xsl:variable name="text-to-wrap"><xsl:call-template name="quote-section" /></xsl:variable>
      <xsl:call-template name="wrap-string">
        <xsl:with-param name="str" select="$text-to-wrap" />
      </xsl:call-template>
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,$block-code-style-names)">
      <xsl:call-template name="code-samples" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,$table-style-names)">
      <xsl:call-template name="table" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,$numbered-list-style-names)">
      <xsl:call-template name="numbered-list" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,$bullet-list-style-names)">
      <xsl:call-template name="list" />
    </xsl:when>
    <xsl:when test="erb:textStyleInheritsFrom(.,$aside-style-names)">
      <xsl:variable name="text-to-wrap"><xsl:call-template name="aside" /></xsl:variable>
      <xsl:call-template name="wrap-string">
        <xsl:with-param name="str" select="$text-to-wrap" />
      </xsl:call-template>
    </xsl:when>
    <!-- Regular Text -->
    <xsl:when test="erb:textStyleInheritsFrom(.,'|Standard|FT|T1|IT|C1_20_Paragraph|Footnote|FC|BodyNoIndent|cd1|Body|')">
      <xsl:variable name="text-to-wrap"><xsl:apply-templates /></xsl:variable>
      <xsl:call-template name="wrap-string">
        <xsl:with-param name="str" select="$text-to-wrap" />
      </xsl:call-template>
      <!-- paragraph break -->
      <xsl:text>

</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="count(text()) > 0 or count(child::*) > 0">
        <xsl:text>[uncaughttext:p:</xsl:text><xsl:value-of select="replace(@text:style-name,'_','\\_')" /><xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="aside">
  <xsl:choose>
    <xsl:when test="@text:style-name='TIH'">
      <xsl:text>\begin{aside}{</xsl:text><xsl:apply-templates /><xsl:text>}
</xsl:text>
    </xsl:when>
    <xsl:otherwise>
      <xsl:if test="not(erb:textStyleInheritsFrom((preceding-sibling::text:p)[last()],$aside-style-names))">
        <xsl:text>\begin{aside}{}</xsl:text>
      </xsl:if>
      <xsl:apply-templates />
    </xsl:otherwise>
  </xsl:choose>
  <xsl:if test="not(erb:textStyleInheritsFrom(following-sibling::text:p[1],'|TIX|TI|'))">
    <xsl:text>
\end{aside}
</xsl:text>
  </xsl:if>
</xsl:template>


<!--Headings -->
<xsl:template name="chapter-heading">
  <xsl:text>\chapter{</xsl:text><xsl:apply-templates /><xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template name="section-heading">
  <xsl:text>\section{</xsl:text><xsl:apply-templates  /><xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template name="sub-section-heading">
  <xsl:text>\subsection{</xsl:text><xsl:apply-templates  /><xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template name="sub-sub-section-heading">
  <xsl:text>\subsubsection{</xsl:text><xsl:apply-templates select=".//text()" /><xsl:text>}
</xsl:text>
</xsl:template>

<xsl:template name="quote-section">
  <xsl:text>\begin{quote}
</xsl:text>
  <xsl:apply-templates />
  <xsl:text>
\end{quote}
</xsl:text>
</xsl:template>

<!-- Inline Code Samples -->
<xsl:template name="inline-code-samples">
  <xsl:text>\verb|</xsl:text>
  <xsl:choose>
    <xsl:when test="count(text())=0 and count(child::text:span) = 1">
      <xsl:call-template name="output-unescaped-text">
        <xsl:with-param name="ending-newline" select="false()" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="output-unescaped-text">
        <xsl:with-param name="ending-newline" select="false()" />
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
  <xsl:text>|</xsl:text>
</xsl:template>

<!-- Block Code Samples -->
<xsl:template name="code-samples">
  <xsl:if test="not(erb:textStyleInheritsFrom((preceding-sibling::text:p)[last()],$block-code-style-names))">
    <xsl:text>\begin{code</xsl:text>
    <xsl:if test="erb:textStyleInheritsFrom(.,'LH')">
      <xsl:text>withtitle}{</xsl:text>
      <xsl:apply-templates />
      <xsl:text>}</xsl:text>
    </xsl:if>
    <xsl:text>}
\begin{Verbatim}
</xsl:text>
  </xsl:if>
  <xsl:if test="count(child::text())=0">
    <xsl:text>
</xsl:text>
  </xsl:if>
  <xsl:call-template name="output-unescaped-text" />
  <xsl:if test="not(erb:textStyleInheritsFrom(following-sibling::text:p[1],$block-code-style-names))">
    <xsl:text>\end{Verbatim}
\end{code}
</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Chapter 1 Table 1.1 -->
<xsl:template name="table">
  <xsl:if test="not(erb:textStyleInheritsFrom((preceding-sibling::text:p)[last()],$table-style-names))">
    <xsl:text>\begin{tabular}{|l|}
\hline
</xsl:text>
  </xsl:if>
  <xsl:apply-templates />
  <xsl:text>\\\hline
</xsl:text>
  <xsl:if test="not(erb:textStyleInheritsFrom((following-sibling::text:p)[1], $table-style-names))">
    <xsl:text>\end{tabular}
</xsl:text>
  </xsl:if>
</xsl:template>

<!-- Various formatted text -->
<xsl:template name="list">
  <xsl:if test="not(erb:textStyleInheritsFrom((preceding-sibling::text:p)[last()], $bullet-list-style-names))">
    <xsl:text>\begin{itemize}
</xsl:text>
  </xsl:if>
  <xsl:text>
\item </xsl:text>
  <xsl:apply-templates />
  <xsl:if test="not(erb:textStyleInheritsFrom((following-sibling::text:p)[1], $bullet-list-style-names))">
    <xsl:text>
\end{itemize}
</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template name="numbered-list">
  <xsl:if test="not(erb:textStyleInheritsFrom((preceding-sibling::text:p)[last()], $numbered-list-style-names))">
    <xsl:text>\begin{enumerate}
</xsl:text>
  </xsl:if>
  <xsl:text>
\item </xsl:text>
  <!-- The first shild node will be the static numbering from word -->
  <xsl:apply-templates />
  <xsl:if test="not(erb:textStyleInheritsFrom((following-sibling::text:p)[1], $numbered-list-style-names))">
    <xsl:text>
\end{enumerate}
</xsl:text>
  </xsl:if>
</xsl:template>

<xsl:template match="text:list">
  <xsl:text>\begin{itemize}
</xsl:text>
  <xsl:apply-templates />
  <xsl:text>\end{itemize}
</xsl:text>
</xsl:template>

<xsl:template match="text:list-item">
  <xsl:text>\item </xsl:text><xsl:apply-templates />
</xsl:template>

<xsl:template match="office:annotation">
  <xsl:variable name="comment">
    <xsl:text>
% On </xsl:text><xsl:value-of select="dc:date" /><xsl:text>
% </xsl:text><xsl:value-of select="dc:creator" /><xsl:text> said: 
% </xsl:text><xsl:value-of select="if(text:p/text:span) then text:p/text:span else text:p" /><xsl:text>
</xsl:text>
  </xsl:variable>
  <xsl:call-template name="wrap-string">
    <xsl:with-param name="str" select="$comment" />
    <xsl:with-param name="wrap-col" select="70" />
    <xsl:with-param name="break-mark">
      <xsl:text>
% </xsl:text>
    </xsl:with-param>
  </xsl:call-template>
</xsl:template>

<!-- regular text formatting -->

<!-- text nodes -->
<xsl:template name="bold-text">
  <xsl:text>\textbf{</xsl:text><xsl:apply-templates /><xsl:text>}

</xsl:text>
</xsl:template>

<xsl:template name="output-unescaped-text">
  <xsl:param name="ending-newline" select="true()" />
  <xsl:for-each select=".//text()">
    <!-- we're only interested in spacer nodes if they come before some text -->
    <xsl:if test="name(preceding-sibling::*[last()]) = 'text:s'">
      <xsl:apply-templates select="preceding-sibling::*[last()]" />
    </xsl:if>
    <xsl:value-of select="." />
  </xsl:for-each>
  <!-- spacer nodes imply that this isn't the end of a line, so skip the newline if this text node is followed by a spacer -->
  <xsl:if test="not(erb:textStyleInheritsFrom(following-sibling::*[1], '|text:s|text:change|text:change-start|text:change-end|') and name(following-sibling::*[1]) != '')">
    <xsl:if test="$ending-newline">
      <xsl:text>
</xsl:text>
    </xsl:if>
  </xsl:if>
</xsl:template>

<xsl:template match="text()">
  <xsl:variable name="twosinglequotes"><xsl:text>''</xsl:text></xsl:variable>
  <xsl:value-of select='replace(replace(replace(replace(replace(replace(replace(replace(.,"_","\\_"),"\$","\\\$"),"“","``"),"”", $twosinglequotes),"•",""), "%", "\\%"), "#","\\#"), "&amp;","\\&amp;")' />
</xsl:template>

<!-- whitespace nodes -->
<xsl:template match="text:line-break">
  <xsl:text>

</xsl:text>
</xsl:template>

<xsl:template match="text:s">
  <xsl:variable name="spaces" select="@text:c" />
  <xsl:choose>
    <xsl:when test="$spaces != ''">
      <xsl:variable name="spaceN" select="$spaces" as="xs:integer" />
      <xsl:value-of select="string-join((for $spaceI in (1 to $spaceN) return ' '),'')" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:text> </xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- From: http://plasmasturm.org/log/204/ -->
<xsl:template name="wrap-string">
    <xsl:param name="str" />
    <xsl:param name="wrap-col" select="72" />
    <xsl:param name="break-mark">
      <xsl:text>
</xsl:text>
    </xsl:param>
    <xsl:param name="pos" select="0" />
    <xsl:choose>
        <xsl:when test="contains( $str, ' ' )">
            <xsl:variable name="before" select="substring-before( $str, ' ' )" />
            <xsl:variable name="pos-now" select="$pos + 1 + string-length( $before )" />

            <xsl:choose>
              <xsl:when test="$pos = 0">
                <xsl:value-of select="$before" />
              </xsl:when>
              <xsl:when test="$pos-now >= $wrap-col">
                <xsl:copy-of select="$break-mark" />
                <xsl:value-of select="$before" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$before" />
              </xsl:otherwise>
            </xsl:choose>


            <xsl:call-template name="wrap-string">
                <xsl:with-param name="str" select="substring-after( $str, ' ' )" />
                <xsl:with-param name="wrap-col" select="$wrap-col" />
                <xsl:with-param name="break-mark" select="$break-mark" />
                <xsl:with-param name="pos" select="if(contains($before, $break-mark)) then string-length(substring-after($before, $break-mark)) else (if($pos-now >= $wrap-col) then string-length($before) else $pos-now)" />
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="$pos > 0"><xsl:text> </xsl:text></xsl:if>
            <xsl:value-of select="$str" />
        </xsl:otherwise>
    </xsl:choose>
</xsl:template>


</xsl:stylesheet>
