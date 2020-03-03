import org.apache.commons.lang3.StringUtils;

/**
 * @Author:Fly
 * @Date:Create in 2020/1/13 下午3:47
 * @Description:
 * @Modified:
 */
public class RedisUtil {

    /**
     *@Author:Fly Created in 2020/1/13 下午3:48
     *@Description: 选择数据库，Redis分库时使用
     */
    public static Integer selectDB(String key){

        return StringUtils.isEmpty(key) ? 0 : key.charAt(0) % 16;
    }
}
