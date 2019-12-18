import org.apache.commons.lang3.StringUtils;
import javax.crypto.Cipher;
import java.security.*;
import java.security.spec.PKCS8EncodedKeySpec;
import java.security.spec.X509EncodedKeySpec;
import java.util.*;

/**
 * @Author:Fly
 * @Date:Create in 2019/7/16 下午4:16
 * @Description: RSA加密
 * @Modified:
 */
public class RsaUtil {

    private final static String ALGORITHM = "RSA";
    private final static List<String> parameter = new ArrayList<>();

    static {

        final String publicKeyBegin = "-----BEGIN PUBLIC KEY-----";
        final String publicKeyEnd = "-----END PUBLIC KEY-----";
        final String privateKeyBegin = "-----BEGIN PRIVATE KEY-----";
        final String privateKeyEnd = "-----END PRIVATE KEY-----";
        final String row = "\n";

        parameter.add(publicKeyBegin);
        parameter.add(publicKeyEnd);
        parameter.add(privateKeyBegin);
        parameter.add(privateKeyEnd);
        parameter.add(row);
    }


    /**
     *@Author:Fly Created in 2019/7/16 下午4:17
     *@Description: 签发秘钥对，可签发多个
     */
    public static KeyPair getKeyPair() throws Exception {
        KeyPairGenerator keyPairGenerator = KeyPairGenerator.getInstance(ALGORITHM);
        keyPairGenerator.initialize(2048);
        KeyPair keyPair = keyPairGenerator.generateKeyPair();
        return keyPair;
    }

    /**
     *@Author:Fly Created in 2019/7/16 下午4:37
     *@Description: 获取签发的秘钥对（公钥存储在map中的key值为：public，私钥key值为：private），可获取多个
     */
    public static Map<String, String> getKeyPairMap(KeyPair keyPair){

        if (Objects.isNull(keyPair)){

            return null;
        }

        Map<String, String> keyPairMap = new HashMap();
        keyPairMap.put("public", Base64Util.enCoderByte(keyPair.getPublic().getEncoded()));
        keyPairMap.put("private", Base64Util.enCoderByte(keyPair.getPrivate().getEncoded()));

        return keyPairMap;
    }

    /**
     *@Author:Fly Created in 2019/7/16 下午4:42
     *@Description: 公钥加密
     */
    public static String publicEncrypt(String context, String publicKeyStr) throws Exception {

        if (StringUtils.isEmpty(context) || StringUtils.isEmpty(publicKeyStr) ){

            return null;
        }

        //去掉秘钥开头、结尾以及换行符
        publicKeyStr = StringUtil.filter(parameter, publicKeyStr);

        X509EncodedKeySpec keySpec = new X509EncodedKeySpec(Base64Util.deCoderByte(publicKeyStr));
        KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM);
        PublicKey publicKey = keyFactory.generatePublic(keySpec);

        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.ENCRYPT_MODE, publicKey);
        String result = Base64Util.enCoderByte(cipher.doFinal(context.getBytes()));

        return result;
    }

    /**
     *@Author:Fly Created in 2019/7/16 下午5:27
     *@Description: 私钥解密
     */
    public static String privateDecrypt(String context, String privateKeyStr) throws Exception {

        if (StringUtils.isEmpty(context) || StringUtils.isEmpty(privateKeyStr)){

            return null;
        }

        //去掉秘钥开头、结尾以及换行符
        privateKeyStr = StringUtil.filter(parameter, privateKeyStr);

        PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(Base64Util.deCoderByte(privateKeyStr));
        KeyFactory keyFactory = KeyFactory.getInstance(ALGORITHM);
        PrivateKey privateKey = keyFactory.generatePrivate(keySpec);

        Cipher cipher = Cipher.getInstance(ALGORITHM);
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        String result = new String(cipher.doFinal(Base64Util.deCoderByte(context)));

        return result;
    }

    /**
     *@Author:Fly Created in 2019/9/3 下午5:25
     *@Description: 测试RSA加密
     */
    public static void main(String[] args) throws Exception {

        Map<String, String> map = RsaUtil.getKeyPairMap(RsaUtil.getKeyPair());
        map.put("public",
                "-----BEGIN PUBLIC KEY-----\n" +
                "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwqi4dE4F3dWHSAGPOBWl\n" +
                "BuGBGfpzACwHbEZEAfYUl7MNJsvnS2UN3TmCo+Ch4EJv06zt5y2SQPqu5Mqd3+8k\n" +
                "Ys7xtdhG0l7cmInbOHfRdr5qzl247p+gGPxmpL2xiCDdysIWfZDRQfA79YfiR3kE\n" +
                "e2tIEPvNa1NYKl1VaIGb0eBWUjKZb1zfmwWJZlPIGJ7Mn2OHHUDBRZdVQxGkOfbk\n" +
                "Xhs/iaKfA81SSx7lC8oH5N06xxZoDpRH9ZmZGLQPUKUPtk6OqYWZej6jMT5pEaC9\n" +
                "DAADLk+7N46UDNL2mNxt2VUdZtzSSs+nA7GpEj1jietEIAh/7rxz16f+o9+Y9WWX\n" +
                "swIDAQAB\n" +
                "-----END PUBLIC KEY-----"
        );
        map.put("private",
                "-----BEGIN PRIVATE KEY-----\n" +
                "MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDCqLh0TgXd1YdI\n" +
                "AY84FaUG4YEZ+nMALAdsRkQB9hSXsw0my+dLZQ3dOYKj4KHgQm/TrO3nLZJA+q7k\n" +
                "yp3f7yRizvG12EbSXtyYids4d9F2vmrOXbjun6AY/GakvbGIIN3KwhZ9kNFB8Dv1\n" +
                "h+JHeQR7a0gQ+81rU1gqXVVogZvR4FZSMplvXN+bBYlmU8gYnsyfY4cdQMFFl1VD\n" +
                "EaQ59uReGz+Jop8DzVJLHuULygfk3TrHFmgOlEf1mZkYtA9QpQ+2To6phZl6PqMx\n" +
                "PmkRoL0MAAMuT7s3jpQM0vaY3G3ZVR1m3NJKz6cDsakSPWOJ60QgCH/uvHPXp/6j\n" +
                "35j1ZZezAgMBAAECggEBAJtLdzxyMoPzoeV0OQoJWorOxOwwviZY+eMLe54E8BDG\n" +
                "K6vT6EZh7FmdU/fhccMzvXsl7vYLiS6Fz5l/e8v3QRQC/RqR3I5gV6Tp9hZqoJUW\n" +
                "/KZ+ZtcYSeUlF84997AeaFMl3EN4kTkFqxAKxB85ELZVtDy4Zf1FlITXyReCrwkT\n" +
                "hOo3W7uWS5+Rn3gAJmkK55gSpTIpQRO/0XB61cBCCFa7Fejnw+1a2JzhUVfswr4l\n" +
                "mqReEk+IIQ83ShKgreAsHiMhnwddA/HUv44CBCJi2WjltMo9lckMRjdc2ZF3diH0\n" +
                "pPH4muOrQ2yGkhBc5T8kjAve3/NYytUf6Gpw8wXdT8ECgYEA/ywuEh47WtiKQLjm\n" +
                "+QuGQ265A9b5WhHAfAVYlhTkIMVvLub2Bs0n58b5lFwzVNK8UExS+o9BskWUUWp7\n" +
                "IccA4Vrn7QNmGNNWoBT5vIdk9jPjB/SdSjJFV9ZVsIXwDifNmS7hDJbqwjFbSWuD\n" +
                "O7YRmRbniC9pDUE9/++8svX1zXsCgYEAw0pO2GzLivWI0nPOjCRMS/2sqTUXMBCZ\n" +
                "0Jo+IHEk0Z2hSjdlpwO177yt33T6oWP+XRBQRbsz3zvWsyLM6Ym/w/kfcp6kKE7i\n" +
                "6cXopsysBXWzgYq6w9+S/0jdbuXkP3L1zpJIrgDLkw3J6hrzoXPLgwpUKisyvcWo\n" +
                "+U5iP/WGXSkCgYBwZ0DAIGsbAIoeKpUsHYR+TdbYNylOIMW+nAhCzF8VhIMOkRTN\n" +
                "ODAc7Exiqx69fbsQUB65WsOgyP+lwZcN8QCVRJsnj7i4tNfS2oqMHsQ9o+udRIbI\n" +
                "+U4MfFDw2n89bREnKjxedFhjRKSmueJsOi6UVj+VgPTwrs2l4TApUSl+4wKBgCNY\n" +
                "0ciOeJDgPDGLUHlBIKYodhXyTA4hExYUtOX+VKG0HDtop3eBTm7kAbyOWcbYaHPD\n" +
                "viPA7HSdShEGXXxvuEvqTWzble7NyHhzn9aA+SnL0f/Ccmd9kgeu0pV9+sAZOLB4\n" +
                "/bqw3ifxuPgshKhWYyGGvxEa3IZIvnrRWyskb3txAoGBALVhXki081bW1LUXQaK6\n" +
                "3A1auK9antAixy3XJCt4ruK7lBtSjjsiuLvmR38XgHp0n3+PVD+9vsor6z+omoCq\n" +
                "QitxtaaDOFhfmVSUob8MRzq3OIHUyq9oGkscmJbg4vpO4sdHYw142XhzLp76Od38\n" +
                "FL2TeNLdBGG9qORcqxPXvOKn\n" +
                "-----END PRIVATE KEY-----"
        );


        String uid = "测试数据";
        String eUid = RsaUtil.publicEncrypt(uid, map.get("public"));
        System.out.println(eUid);
        System.out.println(RsaUtil.privateDecrypt(eUid, map.get("private")));
    }
}
