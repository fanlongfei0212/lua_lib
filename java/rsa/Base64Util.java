import org.apache.commons.lang3.StringUtils;
import java.io.UnsupportedEncodingException;
import java.util.Base64;
import java.util.Objects;

/**
 * @Author:Fly
 * @Date:Create in 2019/7/4 下午2:35
 * @Description: Base64 工具类
 * @Modified:
 */
public class Base64Util {

    private final static Base64.Encoder base64Encoder = Base64.getEncoder();

    private final static Base64.Decoder base64Decoder = Base64.getDecoder();

    private final static String coding = "UTF-8";


    /**
     *@Author:Fly Created in 2019/7/4 下午2:37
     *@Description: Base64加密
     */
    public static String enCoder(String context){

        if (StringUtils.isEmpty(context)){

            return context;
        }

        byte[] result = null;

        try {
            result = context.getBytes(coding);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return base64Encoder.encodeToString(result);
    }

    /**
     *@Author:Fly Created in 2019/7/4 下午2:37
     *@Description: Base64解密
     */
    public static String deCoder(String context){

        if (StringUtils.isEmpty(context)){

            return context;
        }

        String result = null;

        try {
            result = new String(base64Decoder.decode(context), coding);
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }

        return result;
    }

    /**
     *@Author:Fly Created in 2019/7/16 下午4:28
     *@Description: Base64加密
     */
    public static String enCoderByte(byte[] content){

        if (Objects.nonNull(content) && content.length > 0){

            return new String(base64Encoder.encode(content));
        }

        return null;
    }

    /**
     *@Author:Fly Created in 2019/7/16 下午4:30
     *@Description: Base64解密
     */
    public static byte[] deCoderByte(String context){

        if (StringUtils.isNotEmpty(context)){

            return base64Decoder.decode(context);
        }

        return null;
    }
}
