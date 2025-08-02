/*
Language: Luau
Description: Luau is a fast, small, safe, gradually typed embeddable scripting language derived from Lua.
Author: AnotherSubatomo <secretsubatomo@gmail.com>
Category: common, gaming, scripting
Website: https://www.luau.org
*/

export default function(hljs) {
  const OPENING_LONG_BRACKET = '\\[=*\\[';
  const CLOSING_LONG_BRACKET = '\\]=*\\]';
  const LONG_BRACKETS = {
    begin: OPENING_LONG_BRACKET,
    end: CLOSING_LONG_BRACKET,
    contains: [ 'self' ]
  };
  const IDENTIFIER = hljs.UNDERSCORE_IDENT_RE

  const SINGLE_COMMENTS = hljs.COMMENT('--(?!' + OPENING_LONG_BRACKET + ')', '$')
  const BLOCK_COMMENTS = hljs.COMMENT(
    '--' + OPENING_LONG_BRACKET,
    CLOSING_LONG_BRACKET,
    {
      contains: [ LONG_BRACKETS ],
      relevance: 10
    }
  )
  const COMMENTS = [SINGLE_COMMENTS, BLOCK_COMMENTS]

  const BLOCK_STRING = {
    className: 'string',
    begin: OPENING_LONG_BRACKET,
    end: CLOSING_LONG_BRACKET,
    contains: [ LONG_BRACKETS ],
    relevance: 5
  }
  const TYPECAST = {
    begin: IDENTIFIER + '::',
    keywords: {
      keyword: "Self",
      built_in: BUILTINS,
      type: TYPES
    }
  }
  const FUNCTION = {
    className: 'function',
    beginKeywords: 'function',
    end: '\\)',
    contains: [
      hljs.inherit(hljs.TITLE_MODE, { begin: '([_a-zA-Z]\\w*\\.)*([_a-zA-Z]\\w*:)?[_a-zA-Z]\\w*' }),
      {
        className: 'params',
        begin: '\\(',
        endsWithParent: true,
        contains: COMMENTS
      }
    ].concat(COMMENTS)
  }

  const TYPES = "nil string number boolean table function thread userdata vector buffer unknown never any"

  const BUILTINS = 
          // Metatags:
        '__index __newindex __mode __call __metatable __tostring __len __gc __add __sub __mul __div __mod __pow __concat __unm __eq __lt __le '
        // Global functions:
        + '_G _VERSION assert error gcinfo getfenv getmetatable next newproxy print rawequal rawget rawlen rawset select setfenv setmetatable tonumber tostring type typeof ipairs pairs pcall xpcall require unpack '
        // Library methods and properties (one line per library):
        + 'math log max acos huge ldexp pi cos tanh pow deg tan cosh sinh random randomseed frexp ceil floor rad abs sqrt modf asin min mod fmod log10 atan2 exp sin atan lerp noise clamp sign round '
        + 'table concat foreach foreachi getn maxn insert remove sort pack unpack move create find clear freeze isfrozen clone '
        + 'string byte char find format gmatch gsub len lower match rep reverse sub upper split pack packsize unpack '
        + 'coroutine create running status wrap yield isyieldable resume close '
        + 'bit32 arshift band bnot bor bxor btest extract lrotate lshift replace rrotate rshift countlz countrz byteswap '
        + 'utf8 offset codepoint char len codes '
        + 'os clock date difftime time '
        + 'debug info traceback '
        + 'buffer create fromstring tostring len readi8 readu8 readi16 readu16 readi32 readu32 readf32 readf64 writei8 writeu8 writei16 writeu16 writei32 writeu32 writef32 writef64 readstring writestring copy fill '
        + 'vector zero one create magnitude normalize cross dot angle floor ceil abs sign clamp max min'

  return {
    name: 'Lua',
    aliases: ['luau'],
    keywords: {
      $pattern: IDENTIFIER,
      type: TYPES,
      literal: "true false nil",
      keyword: "and break continue do else elseif end for if in local not or repeat return self then until while",
      built_in: BUILTINS
    },
    contains: [
      FUNCTION,
      hljs.C_NUMBER_MODE,
      hljs.APOS_STRING_MODE,
      hljs.QUOTE_STRING_MODE,
      BLOCK_STRING,
      TYPECAST
    ].concat(COMMENTS)
  };
}