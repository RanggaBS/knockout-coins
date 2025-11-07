@ECHO OFF

luac -s _combined.lua

IF EXIST _combined.lur (
  DEL _combined.lur
)

RENAME luac.out _combined.lur
