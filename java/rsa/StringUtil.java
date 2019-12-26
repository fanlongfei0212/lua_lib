import org.apache.commons.lang3.StringUtils;
import java.util.List;
import java.util.Objects;

/**
 * @Author:Fly
 * @Date:Create in 2019/9/3 下午4:07
 * @Description: 字符串工具类
 * @Modified:
 */
public class StringUtil {

    /**
     *@Author:Fly Created in 2019/9/3 下午4:08
     *@Description: 指定过滤字符串中的字符
     */
    public static String filter(List<String> parameters, String context){

        if (StringUtils.isEmpty(context) || (Objects.isNull(parameters) || parameters.size() == 0)){

            return null;
        }

        if (parameters.stream().anyMatch(obj -> StringUtils.isEmpty(obj))){

            return null;
        }

        for(String pa : parameters){

            context = context.replaceAll(pa, "");
        }

        return context;
    }
}
