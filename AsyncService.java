package com.github.mimiknight.kuca.easy.service.standard;

import java.util.concurrent.CompletableFuture;
import java.util.function.BiConsumer;
import java.util.function.Consumer;
import java.util.function.Function;
import java.util.function.Supplier;

/**
 * 异步任务服务接口
 *
 * @author MiMiKnight victor2015yhm@gmail.com
 * @since 2023-11-11 08:19:43
 */
public interface AsyncService {

    /**
     * 异步任务方法
     *
     * @param action        异步任务代码逻辑
     * @param whenComplete  action正常执行或者异常执行完成后执行whenComplete
     * @param whenException action或者whenComplete中发生异常才执行whenException
     */
    void async(Runnable action, Consumer<Throwable> whenComplete, Consumer<Throwable> whenException);

    /**
     * 异步执行方法
     *
     * @param action 异步任务代码逻辑
     */
    void async(Runnable action);

    /**
     * 异步任务方法
     *
     * @param action        异步任务代码逻辑
     * @param whenComplete  action正常执行或者异常执行完成后执行whenComplete
     * @param whenException action或者whenComplete中发生异常才执行whenException
     * @return {@link CompletableFuture}<{@link T}>
     */
    <T> CompletableFuture<T> async(Supplier<T> action, BiConsumer<T, Throwable> whenComplete, Function<Throwable, T> whenException);
}
