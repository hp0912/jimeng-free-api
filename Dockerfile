FROM node:lts AS BUILD_IMAGE

WORKDIR /app

# 先复制 package.json 和 yarn.lock (如果存在) 以利用 Docker 层缓存
COPY package.json yarn.lock* ./

# 安装依赖
RUN yarn install --registry https://registry.npmmirror.com/ --ignore-engines --frozen-lockfile

# 再复制源代码
COPY . .

# 构建项目
RUN yarn run build

FROM node:lts-alpine

WORKDIR /app

# 复制构建产物
COPY --from=BUILD_IMAGE /app/package.json ./
COPY --from=BUILD_IMAGE /app/node_modules ./node_modules
COPY --from=BUILD_IMAGE /app/dist ./dist
COPY --from=BUILD_IMAGE /app/public ./public
COPY --from=BUILD_IMAGE /app/configs ./configs

EXPOSE 9000

CMD ["npm", "start"]