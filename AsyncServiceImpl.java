package com.github.mimiknight.kuca.easy.service.impl;

import com.github.mimiknight.kuca.easy.service.standard.AsyncService;
import com.github.mimiknight.kuca.easy.utils.AppUtils;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.scheduling.concurrent.ThreadPoolTaskExecutor;

import java.util.concurrent.CompletableFuture;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

/**
 * 异步任务服务类
 * <p>
 * 异步任务的线程池配置禁止设置CallerRunsPolicy饱和策略【ThreadPoolExecutor.CallerRunsPolicy()】
 * 因为CallerRunsPolicy策略，当线程达到最大线程池数量且等待队列满时，会使用调用者的线程执行任务，
 * 这样可能导致 MDC.clear()清理掉父线程中的"日志跟踪ID"，给日志追踪带来麻烦；
 *
 * @author MiMiKnight victor2015yhm@gmail.com
 * @since 2023-11-11 08:20:09
 */
@Slf4j
public class AsyncServiceImpl implements AsyncService, ApplicationContextAware, InitializingBean {

    private ThreadPoolTaskExecutor executor;
    private ApplicationContext appContext;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.appContext = applicationContext;
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        this.executor = appContext.getBean("appAsyncThreadPool", ThreadPoolTaskExecutor.class);
    }


    @Override
    public void async(Runnable action, Consumer<Throwable> whenComplete, Consumer<Throwable> whenException) {
        String traceId = AppUtils.getThreadTraceId();
        // 调用者线程
        Thread callerThread = Thread.currentThread();
        CompletableFuture.runAsync(() -> {
            // 设置子线程的“日志跟踪ID”
            if (!Thread.currentThread().equals(callerThread)) {
                AppUtils.setThreadTraceId(traceId);
            }
            action.run();
        }, executor).whenComplete((v, ex) -> {
            try {
                if (null != whenComplete) {
                    whenComplete.accept(ex);
                }
            } finally {
                // 清理子线程中设置的“日志跟踪ID”
                if (null == ex && !Thread.currentThread().equals(callerThread)) {
                    AppUtils.clearThreadTraceId();
                }
            }
        }).exceptionally(ex -> {
            try {
                if (null != whenException) {
                    whenException.accept(ex);
                }
                return null;
            } finally {
                // 清理子线程中设置的“日志跟踪ID”
                if (!Thread.currentThread().equals(callerThread)) {
                    AppUtils.clearThreadTraceId();
                }
            }
        });
    }

    @Override
    public void async(Runnable action) {
        async(action, ex -> {
            if (null != ex) {
                log.info("The async task business run success");
            }
        }, ex -> {
            log.error("The async task business run exception");
            log.error(AppUtils.buildExceptionLogTip(ex));
        });
    }

    @Override
    public <T> CompletableFuture<T> async(Supplier<T> action, BiConsumer<T, Throwable> whenComplete, Function<Throwable, T> whenException) {
        String traceId = AppUtils.getThreadTraceId();
        // 调用者线程
        Thread callerThread = Thread.currentThread();
        return CompletableFuture.supplyAsync(() -> {
            // 设置子线程的“日志跟踪ID”
            if (!Thread.currentThread().equals(callerThread)) {
                AppUtils.setThreadTraceId(traceId);
            }
            return action.get();
        }, executor).whenComplete((v, ex) -> {
            try {
                if (null != whenComplete) {
                    whenComplete.accept(v, ex);
                }
            } finally {
                // 清理子线程中设置的“日志跟踪ID”
                if (null == ex && !Thread.currentThread().equals(callerThread)) {
                    AppUtils.clearThreadTraceId();
                }
            }
        }).exceptionally(ex -> {
            try {
                return whenException.apply(ex);
            } finally {
                // 清理子线程中设置的“日志跟踪ID”
                if (!Thread.currentThread().equals(callerThread)) {
                    AppUtils.clearThreadTraceId();
                }
            }
        });
    }

}
