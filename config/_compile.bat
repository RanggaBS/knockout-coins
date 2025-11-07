@ECHO OFF

luac -s config_ae.lua

IF EXIST config_ae.lur (
  DEL config_ae.lur
)

RENAME luac.out config_ae.lur
