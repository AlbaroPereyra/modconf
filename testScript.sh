#! /bin/sh -
conf="conf2";
> $conf
echo "key=value" > $conf;
cat $conf;
key="key";
delimiter="=";
value="value";
sed -i .bak "s/$key=value/# key=value/" "$conf";
cat $conf
echo "$(date)";
