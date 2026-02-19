<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
  <xsl:template name="get-language-name">
    <xsl:param name="code"/>
      <xsl:choose>
      <xsl:when test= "$code = 'aa'">Afar</xsl:when>
      <xsl:when test= "$code = 'ab'">Abkhaz</xsl:when>
      <xsl:when test= "$code = 'ae'">Avestan</xsl:when>
      <xsl:when test= "$code = 'af'">Afrikaans</xsl:when>
      <xsl:when test= "$code = 'ak'">Akan</xsl:when>
      <xsl:when test= "$code = 'am'">Amharic</xsl:when>
      <xsl:when test= "$code = 'an'">Aragonese</xsl:when>
      <xsl:when test= "$code = 'ar'">Arabic</xsl:when>
      <xsl:when test= "$code = 'as'">Assamese</xsl:when>
      <xsl:when test= "$code = 'av'">Avaric</xsl:when>
      <xsl:when test= "$code = 'ay'">Aymara</xsl:when>
      <xsl:when test= "$code = 'az'">Azerbaijani</xsl:when>
      <xsl:when test= "$code = 'ba'">Bashkir</xsl:when>
      <xsl:when test= "$code = 'be'">Belarusian</xsl:when>
      <xsl:when test= "$code = 'bg'">Bulgarian</xsl:when>
      <xsl:when test= "$code = 'bh'">Bihari</xsl:when>
      <xsl:when test= "$code = 'bi'">Bislama</xsl:when>
      <xsl:when test= "$code = 'bm'">Bambara</xsl:when>
      <xsl:when test= "$code = 'bn'">Bengali, Bangla</xsl:when>
      <xsl:when test= "$code = 'bo'">Tibetan Standard, Tibetan, Central</xsl:when>
      <xsl:when test= "$code = 'br'">Breton</xsl:when>
      <xsl:when test= "$code = 'bs'">Bosnian</xsl:when>
      <xsl:when test= "$code = 'ca'">Catalan</xsl:when>
      <xsl:when test= "$code = 'ce'">Chechen</xsl:when>
      <xsl:when test= "$code = 'ch'">Chamorro</xsl:when>
      <xsl:when test= "$code = 'co'">Corsican</xsl:when>
      <xsl:when test= "$code = 'cr'">Cree</xsl:when>
      <xsl:when test= "$code = 'cs'">Czech</xsl:when>
      <xsl:when test= "$code = 'cu'">Old Church Slavonic, Church Slavonic, Old Bulgarian</xsl:when>
      <xsl:when test= "$code = 'cv'">Chuvash</xsl:when>
      <xsl:when test= "$code = 'cy'">Welsh</xsl:when>
      <xsl:when test= "$code = 'da'">Danish</xsl:when>
      <xsl:when test= "$code = 'de'">German</xsl:when>
      <xsl:when test= "$code = 'dv'">Divehi, Dhivehi, Maldivian</xsl:when>
      <xsl:when test= "$code = 'dz'">Dzongkha</xsl:when>
      <xsl:when test= "$code = 'ee'">Ewe</xsl:when>
      <xsl:when test= "$code = 'el'">Greek (modern)</xsl:when>
      <xsl:when test= "$code = 'en'">English</xsl:when>
      <xsl:when test= "$code = 'eo'">Esperanto</xsl:when>
      <xsl:when test= "$code = 'es'">Spanish</xsl:when>
      <xsl:when test= "$code = 'et'">Estonian</xsl:when>
      <xsl:when test= "$code = 'eu'">Basque</xsl:when>
      <xsl:when test= "$code = 'fa'">Persian (Farsi)</xsl:when>
      <xsl:when test= "$code = 'ff'">Fula, Fulah, Pulaar, Pular</xsl:when>
      <xsl:when test= "$code = 'fi'">Finnish</xsl:when>
      <xsl:when test= "$code = 'fj'">Fijian</xsl:when>
      <xsl:when test= "$code = 'fo'">Faroese</xsl:when>
      <xsl:when test= "$code = 'fr'">French</xsl:when>
      <xsl:when test= "$code = 'fy'">Western Frisian</xsl:when>
      <xsl:when test= "$code = 'ga'">Irish</xsl:when>
      <xsl:when test= "$code = 'gd'">Scottish Gaelic, Gaelic</xsl:when>
      <xsl:when test= "$code = 'gl'">Galician</xsl:when>
      <xsl:when test= "$code = 'gn'">Guaraní</xsl:when>
      <xsl:when test= "$code = 'gu'">Gujarati</xsl:when>
      <xsl:when test= "$code = 'gv'">Manx</xsl:when>
      <xsl:when test= "$code = 'ha'">Hausa</xsl:when>
      <xsl:when test= "$code = 'he'">Hebrew (modern)</xsl:when>
      <xsl:when test= "$code = 'hi'">Hindi</xsl:when>
      <xsl:when test= "$code = 'ho'">Hiri Motu</xsl:when>
      <xsl:when test= "$code = 'hr'">Croatian</xsl:when>
      <xsl:when test= "$code = 'ht'">Haitian, Haitian Creole</xsl:when>
      <xsl:when test= "$code = 'hu'">Hungarian</xsl:when>
      <xsl:when test= "$code = 'hy'">Armenian</xsl:when>
      <xsl:when test= "$code = 'hz'">Herero</xsl:when>
      <xsl:when test= "$code = 'ia'">Interlingua</xsl:when>
      <xsl:when test= "$code = 'id'">Indonesian</xsl:when>
      <xsl:when test= "$code = 'ie'">Interlingue</xsl:when>
      <xsl:when test= "$code = 'ig'">Igbo</xsl:when>
      <xsl:when test= "$code = 'ii'">Nuosu</xsl:when>
      <xsl:when test= "$code = 'ik'">Inupiaq</xsl:when>
      <xsl:when test= "$code = 'io'">Ido</xsl:when>
      <xsl:when test= "$code = 'is'">Icelandic</xsl:when>
      <xsl:when test= "$code = 'it'">Italian</xsl:when>
      <xsl:when test= "$code = 'iu'">Inuktitut</xsl:when>
      <xsl:when test= "$code = 'ja'">Japanese</xsl:when>
      <xsl:when test= "$code = 'jv'">Javanese</xsl:when>
      <xsl:when test= "$code = 'ka'">Georgian</xsl:when>
      <xsl:when test= "$code = 'kg'">Kongo</xsl:when>
      <xsl:when test= "$code = 'ki'">Kikuyu, Gikuyu</xsl:when>
      <xsl:when test= "$code = 'kj'">Kwanyama, Kuanyama</xsl:when>
      <xsl:when test= "$code = 'kk'">Kazakh</xsl:when>
      <xsl:when test= "$code = 'kl'">Kalaallisut, Greenlandic</xsl:when>
      <xsl:when test= "$code = 'km'">Khmer</xsl:when>
      <xsl:when test= "$code = 'kn'">Kannada</xsl:when>
      <xsl:when test= "$code = 'ko'">Korean</xsl:when>
      <xsl:when test= "$code = 'kr'">Kanuri</xsl:when>
      <xsl:when test= "$code = 'ks'">Kashmiri</xsl:when>
      <xsl:when test= "$code = 'ku'">Kurdish</xsl:when>
      <xsl:when test= "$code = 'kv'">Komi</xsl:when>
      <xsl:when test= "$code = 'kw'">Cornish</xsl:when>
      <xsl:when test= "$code = 'ky'">Kyrgyz</xsl:when>
      <xsl:when test= "$code = 'la'">Latin</xsl:when>
      <xsl:when test= "$code = 'lb'">Luxembourgish, Letzeburgesch</xsl:when>
      <xsl:when test= "$code = 'lg'">Ganda</xsl:when>
      <xsl:when test= "$code = 'li'">Limburgish, Limburgan, Limburger</xsl:when>
      <xsl:when test= "$code = 'ln'">Lingala</xsl:when>
      <xsl:when test= "$code = 'lo'">Lao</xsl:when>
      <xsl:when test= "$code = 'lt'">Lithuanian</xsl:when>
      <xsl:when test= "$code = 'lu'">Luba-Katanga</xsl:when>
      <xsl:when test= "$code = 'lv'">Latvian</xsl:when>
      <xsl:when test= "$code = 'mg'">Malagasy</xsl:when>
      <xsl:when test= "$code = 'mh'">Marshallese</xsl:when>
      <xsl:when test= "$code = 'mi'">Māori</xsl:when>
      <xsl:when test= "$code = 'mk'">Macedonian</xsl:when>
      <xsl:when test= "$code = 'ml'">Malayalam</xsl:when>
      <xsl:when test= "$code = 'mn'">Mongolian</xsl:when>
      <xsl:when test= "$code = 'mr'">Marathi (Marāṭhī)</xsl:when>
      <xsl:when test= "$code = 'ms'">Malay</xsl:when>
      <xsl:when test= "$code = 'mt'">Maltese</xsl:when>
      <xsl:when test= "$code = 'my'">Burmese</xsl:when>
      <xsl:when test= "$code = 'na'">Nauruan</xsl:when>
      <xsl:when test= "$code = 'nb'">Norwegian Bokmål</xsl:when>
      <xsl:when test= "$code = 'nd'">Northern Ndebele</xsl:when>
      <xsl:when test= "$code = 'ne'">Nepali</xsl:when>
      <xsl:when test= "$code = 'ng'">Ndonga</xsl:when>
      <xsl:when test= "$code = 'nl'">Dutch</xsl:when>
      <xsl:when test= "$code = 'nn'">Norwegian Nynorsk</xsl:when>
      <xsl:when test= "$code = 'no'">Norwegian</xsl:when>
      <xsl:when test= "$code = 'nr'">Southern Ndebele</xsl:when>
      <xsl:when test= "$code = 'nv'">Navajo, Navaho</xsl:when>
      <xsl:when test= "$code = 'ny'">Chichewa, Chewa, Nyanja</xsl:when>
      <xsl:when test= "$code = 'oc'">Occitan</xsl:when>
      <xsl:when test= "$code = 'oj'">Ojibwe, Ojibwa</xsl:when>
      <xsl:when test= "$code = 'om'">Oromo</xsl:when>
      <xsl:when test= "$code = 'or'">Oriya</xsl:when>
      <xsl:when test= "$code = 'os'">Ossetian, Ossetic</xsl:when>
      <xsl:when test= "$code = 'pa'">(Eastern) Punjabi</xsl:when>
      <xsl:when test= "$code = 'pi'">Pāli</xsl:when>
      <xsl:when test= "$code = 'pl'">Polish</xsl:when>
      <xsl:when test= "$code = 'ps'">Pashto, Pushto</xsl:when>
      <xsl:when test= "$code = 'pt'">Portuguese</xsl:when>
      <xsl:when test= "$code = 'qu'">Quechua</xsl:when>
      <xsl:when test= "$code = 'rm'">Romansh</xsl:when>
      <xsl:when test= "$code = 'rn'">Kirundi</xsl:when>
      <xsl:when test= "$code = 'ro'">Romanian</xsl:when>
      <xsl:when test= "$code = 'ru'">Russian</xsl:when>
      <xsl:when test= "$code = 'rw'">Kinyarwanda</xsl:when>
      <xsl:when test= "$code = 'sa'">Sanskrit (Saṁskṛta)</xsl:when>
      <xsl:when test= "$code = 'sc'">Sardinian</xsl:when>
      <xsl:when test= "$code = 'sd'">Sindhi</xsl:when>
      <xsl:when test= "$code = 'se'">Northern Sami</xsl:when>
      <xsl:when test= "$code = 'sg'">Sango</xsl:when>
      <xsl:when test= "$code = 'si'">Sinhalese, Sinhala</xsl:when>
      <xsl:when test= "$code = 'sk'">Slovak</xsl:when>
      <xsl:when test= "$code = 'sl'">Slovene</xsl:when>
      <xsl:when test= "$code = 'sm'">Samoan</xsl:when>
      <xsl:when test= "$code = 'sn'">Shona</xsl:when>
      <xsl:when test= "$code = 'so'">Somali</xsl:when>
      <xsl:when test= "$code = 'sq'">Albanian</xsl:when>
      <xsl:when test= "$code = 'sr'">Serbian</xsl:when>
      <xsl:when test= "$code = 'ss'">Swati</xsl:when>
      <xsl:when test= "$code = 'st'">Southern Sotho</xsl:when>
      <xsl:when test= "$code = 'su'">Sundanese</xsl:when>
      <xsl:when test= "$code = 'sv'">Swedish</xsl:when>
      <xsl:when test= "$code = 'sw'">Swahili</xsl:when>
      <xsl:when test= "$code = 'ta'">Tamil</xsl:when>
      <xsl:when test= "$code = 'te'">Telugu</xsl:when>
      <xsl:when test= "$code = 'tg'">Tajik</xsl:when>
      <xsl:when test= "$code = 'th'">Thai</xsl:when>
      <xsl:when test= "$code = 'ti'">Tigrinya</xsl:when>
      <xsl:when test= "$code = 'tk'">Turkmen</xsl:when>
      <xsl:when test= "$code = 'tl'">Tagalog</xsl:when>
      <xsl:when test= "$code = 'tn'">Tswana</xsl:when>
      <xsl:when test= "$code = 'to'">Tonga (Tonga Islands)</xsl:when>
      <xsl:when test= "$code = 'tr'">Turkish</xsl:when>
      <xsl:when test= "$code = 'ts'">Tsonga</xsl:when>
      <xsl:when test= "$code = 'tt'">Tatar</xsl:when>
      <xsl:when test= "$code = 'tw'">Twi</xsl:when>
      <xsl:when test= "$code = 'ty'">Tahitian</xsl:when>
      <xsl:when test= "$code = 'ug'">Uyghur</xsl:when>
      <xsl:when test= "$code = 'uk'">Ukrainian</xsl:when>
      <xsl:when test= "$code = 'ur'">Urdu</xsl:when>
      <xsl:when test= "$code = 'uz'">Uzbek</xsl:when>
      <xsl:when test= "$code = 've'">Venda</xsl:when>
      <xsl:when test= "$code = 'vi'">Vietnamese</xsl:when>
      <xsl:when test= "$code = 'vo'">Volapük</xsl:when>
      <xsl:when test= "$code = 'wa'">Walloon</xsl:when>
      <xsl:when test= "$code = 'wo'">Wolof</xsl:when>
      <xsl:when test= "$code = 'xh'">Xhosa</xsl:when>
      <xsl:when test= "$code = 'yi'">Yiddish</xsl:when>
      <xsl:when test= "$code = 'yo'">Yoruba</xsl:when>
      <xsl:when test= "$code = 'za'">Zhuang, Chuang</xsl:when>
      <xsl:when test= "$code = 'zh'">Chinese</xsl:when>
      <xsl:when test= "$code = 'zu'">Zulu</xsl:when>
      <xsl:otherwise>Unknown</xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
